import 'dart:async';

import 'package:flutter/material.dart';

import 'memory_game.dart'; // Ensure gif_view: ^1.0.1 in pubspec.yaml
import 'difficulty_screen.dart';

class ReadyGoScreen extends StatefulWidget {
  final DifficultyLevel difficultyLevel;

  const ReadyGoScreen({
    super.key,
    required this.difficultyLevel,
  });

  @override
  ReadyGoScreenState createState() => ReadyGoScreenState();
}

class ReadyGoScreenState extends State<ReadyGoScreen> {
  String text = "Ready?";
  bool isGo = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          text = "GO!";
          isGo = true;
        });
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MemoryGame(
                  difficultyLevel: widget.difficultyLevel,
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            text,
            key: ValueKey<String>(text),
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: isGo ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }
}
