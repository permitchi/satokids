import 'package:flutter/material.dart';
import 'package:satokids/data/user_data.dart';
import 'package:satokids/level_select.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/level_data.dart';
import 'minigames/matching_game.dart';
import 'minigames/scrambled_word_game.dart';
import 'minigames/memory_game.dart';
import 'minigames/true_false_game.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int gameType;

  const GameScreen({super.key, required this.level, required this.gameType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isGameFinished = false;
  bool _isExiting = false;

  void _finishGame() {
    setState(() {
      isGameFinished = true;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.orange, size: 80),
              const SizedBox(height: 20),
              Text(
                "Level ${widget.level} Complete!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Great job! You finished the game.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    ).then((result) async {
      if (result == true && mounted) {
        // Save progress before navigating back
        await UserDataManager.addPoints(15);
        await UserDataManager.logLevelCompletion(widget.level);

        final prefs = await SharedPreferences.getInstance();
        int completed = prefs.getInt('completedLevels') ?? 0;
        if (widget.level > completed) {
          await prefs.setInt('completedLevels', widget.level);
        }

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                (route) => route.isFirst,
          );
        }
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isGameFinished || _isExiting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Quit Level?"),
            content: const Text("You will lose your progress in this level. Are you sure?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Keep Playing"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          setState(() {
            _isExiting = true;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                (route) => route.isFirst,
          );        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 80, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMinigameUI(),
                  ],
                ),
              ),
            ),
            // Back Button
            Positioned(
              top: 10,
              left: 10,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinigameUI() {
    final items = getLevelItems(widget.level);
    
    // Exception for Level 10: True/False Game
    if (widget.level == 10) {
      return TrueFalseGame(items: items, onFinish: _finishGame);
    }

    switch (widget.gameType) {
      case 1:
        return MatchingGame(items: items, onFinish: _finishGame);
      case 2:
        return ScrambledWordGame(items: items, onFinish: _finishGame);
      case 3:
        return MemoryGame(items: items, onFinish: _finishGame);
      default:
        return const Text("Unknown Game");
    }
  }
}
