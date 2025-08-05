import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sequence_match/src/win_screen.dart';
import 'package:sequence_match/src/difficulty_screen.dart';

import 'lost_screen.dart'; // Ensure gif_view: ^1.0.1 in pubspec.yaml

class MemoryGame extends StatefulWidget {
  final DifficultyLevel difficultyLevel;

  const MemoryGame({
    super.key,
    required this.difficultyLevel,
  });

  @override
  MemoryGameState createState() => MemoryGameState();
}

class MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  late List<int> numbers;
  late List<bool> revealed;
  int nextNumber = 1;
  int attempts = 0;
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  String? lastMessage;
  bool isMemorizationPhase = true;
  int lastMessageAttempt = 0;
  bool showMessage = false;
  String currentMessage = '';
  AnimationController? messageController;
  Animation<double>? messageAnimation;

  late int remainingSeconds;
  Timer? gameTimer;
  Timer? memorizationTimer;
  Timer? messageTimer;

  final List<String> gentleMessages = [
    "🤔 Take your time...",
    "💭 Think about it...",
    "🎯 Focus on the sequence",
    "⏳ You've got this!",
    "🌟 Keep trying!",
    "💪 Stay focused!",
    "🎮 Remember the pattern",
    "✨ You're getting closer!",
  ];

  final List<String> mediumMessages = [
    "😅 That was close!",
    "🔄 Try again!",
    "🎯 Almost there!",
    "💫 Keep going!",
    "🎮 Remember the numbers",
    "🌟 You can do it!",
    "💪 Stay determined!",
    "✨ Don't give up!",
  ];

  final List<String> harshMessages = [
    "😂 That was… something!",
    "🙈 My grandma taps better!",
    "🤡 Nice try, clown!",
    "💀 That was tragic.",
    "📉 Your skills are declining!",
    "👀 Were you even trying?",
    "🤦‍♂️ Wow… just wow.",
    "🐢 That was slow AND wrong!",
    "🎯 You missed… badly!",
    "🤔 You okay there, champ?",
    "🔥 So close! (Not really)",
    "👎 That was embarrassing!",
    "🛑 Stop. Think. Tap again.",
    "🍕 You play like a melted pizza!",
    "💨 Blinked and missed it!",
    "⚰️ RIP that attempt!",
    "😂 You should frame that fail!",
    "🔄 Wanna try actually winning?",
    "💡 Pro tip: Tap the right one!",
    "🎭 Comedy gold! Keep failing!",
  ];

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.difficultyLevel.timeInSeconds;
    _shuffleNumbers();
    _setupAnimations();
    _setupMessageAnimation();

    // Start memorization phase
    memorizationTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        isMemorizationPhase = false;
        revealed = List.filled(numbers.length, false);
      });
    });

    // Start the game Timer
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
        if (remainingSeconds <= 0) {
          timer.cancel();
          // If time is up, go to LostScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LostScreen(
                difficultyLevel: widget.difficultyLevel,
              ),
            ),
          );
        }
      });
    });
  }

  void _shuffleNumbers() {
    setState(() {
      final gridSize = widget.difficultyLevel.gridSize;
      final totalTiles = gridSize * gridSize;
      numbers = List.generate(totalTiles, (index) => index + 1)..shuffle();
      revealed = List.filled(totalTiles, false);
      nextNumber = 1;
      attempts = 0;
      _resetAnimations();
    });
  }

  void _setupAnimations() {
    // Dispose old controllers if any
    for (var c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _animations.clear();

    final totalTiles = widget.difficultyLevel.gridSize * widget.difficultyLevel.gridSize;
    _controllers = List.generate(
      totalTiles,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  void _setupMessageAnimation() {
    messageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: messageController!,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _onTileTap(int index) {
    if (revealed[index]) return;

    setState(() {
      _controllers[index].forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        revealed[index] = true;

        if (numbers[index] == nextNumber) {
          nextNumber++;
          if (nextNumber > numbers.length) {
            // Player won, cancel the timer
            gameTimer?.cancel();
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WinScreen(
                    attempts: attempts,
                    difficultyLevel: widget.difficultyLevel,
                  ),
                ),
              );
            });
          }
        } else {
          attempts++;
          Future.delayed(const Duration(milliseconds: 400), () {
            setState(() {
              revealed = List.filled(numbers.length, false);
              nextNumber = 1;
              _resetAnimations();
            });
            _showBlameMessage();
          });
        }
      });
    });
  }

  void _resetAnimations() {
    for (var controller in _controllers) {
      controller.reverse();
    }
  }

  void _showBlameMessage() {
    // Only show message if enough attempts have passed since last message
    if (attempts - lastMessageAttempt < 3) return;

    // Random chance to show message (50% probability)
    if (Random().nextDouble() > 0.5) return;

    String newMessage;
    List<String> messagePool;

    // Select message pool based on number of attempts
    if (attempts <= 5) {
      messagePool = gentleMessages;
    } else if (attempts <= 10) {
      messagePool = mediumMessages;
    } else {
      messagePool = harshMessages;
    }

    // Get a random message from the selected pool
    do {
      newMessage = messagePool[Random().nextInt(messagePool.length)];
    } while (newMessage == lastMessage);

    lastMessage = newMessage;
    lastMessageAttempt = attempts;

    setState(() {
      currentMessage = newMessage;
      showMessage = true;
    });

    // Reset and start animation
    messageController?.reset();
    messageController?.forward();

    // Cancel any existing message timer
    messageTimer?.cancel();

    // Set new timer to hide message
    messageTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showMessage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    messageController?.dispose();
    gameTimer?.cancel();
    memorizationTimer?.cancel();
    messageTimer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      appBar: AppBar(
        title: const Text("Sequence Match"),
        backgroundColor: const Color(0xFFFF7043),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Give Up?'),
                    content: const Text('Are you sure you want to give up?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No, Keep Playing'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DifficultyScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Yes, Give Up',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.stop_circle, color: Colors.white),
            label: const Text(
              'Give Up',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Time Left: ${formatTime(remainingSeconds)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              remainingSeconds <= 20 ? Colors.red : Colors.black),
                    ),
                  ),
                ),
                // Grid
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: numbers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.difficultyLevel.gridSize,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _onTileTap(index),
                      child: AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          final angle = _animations[index].value;
                          final isFront = angle < pi / 2;

                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(angle),
                            child: Stack(
                              children: [
                                _buildTile(index, false),
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: isFront
                                      ? Container()
                                      : _buildTile(index, true),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (showMessage)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: messageAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: messageAnimation!.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        currentMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(int index, bool isRevealed) {
    return Container(
      decoration: BoxDecoration(
        color: isRevealed || isMemorizationPhase ? const Color(0xFF4FC3F7) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: (isRevealed || isMemorizationPhase)
            ? Text(
                "${numbers[index]}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Container(),
      ),
    );
  }
}
