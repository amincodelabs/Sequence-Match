import 'package:flutter/material.dart';
import 'package:sequence_match/src/ready_go_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Difficulty',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7043),
                ),
              ),
              const SizedBox(height: 40),
              _buildDifficultyButton(
                context,
                'Easy',
                '${_getGridSizeText(DifficultyLevel.easy)}\n${_getTimeText(DifficultyLevel.easy)}',
                Colors.green,
                () => _startGame(context, DifficultyLevel.easy),
              ),
              const SizedBox(height: 20),
              _buildDifficultyButton(
                context,
                'Medium',
                '${_getGridSizeText(DifficultyLevel.medium)}\n${_getTimeText(DifficultyLevel.medium)}',
                Colors.orange,
                () => _startGame(context, DifficultyLevel.medium),
              ),
              const SizedBox(height: 20),
              _buildDifficultyButton(
                context,
                'Hard',
                '${_getGridSizeText(DifficultyLevel.hard)}\n${_getTimeText(DifficultyLevel.hard)}',
                Colors.red,
                () => _startGame(context, DifficultyLevel.hard),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getGridSizeText(DifficultyLevel level) {
    return '${level.gridSize}x${DifficultyLevel.hard.gridSize} Grid';
  }
  
  String _getTimeText(DifficultyLevel level) {
    return '${(level.timeInSeconds/60).toInt()} Minute';
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, DifficultyLevel level) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReadyGoScreen(difficultyLevel: level),
      ),
    );
  }
}

enum DifficultyLevel {
  easy,
  medium,
  hard;

  int get gridSize {
    switch (this) {
      case DifficultyLevel.easy:
        return 4;
      case DifficultyLevel.medium:
        return 5;
      case DifficultyLevel.hard:
        return 6;
    }
  }

  int get timeInSeconds {
    switch (this) {
      case DifficultyLevel.easy:
        return 180; // 3 minutes
      case DifficultyLevel.medium:
        return 120; // 2 minutes
      case DifficultyLevel.hard:
        return 180; // 3 minute
    }
  }
} 