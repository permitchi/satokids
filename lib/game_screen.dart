import 'package:flutter/material.dart';
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
    ).then((result) {
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isGameFinished,
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
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Level ${widget.level} - Game ${widget.gameType}"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMinigameUI(),
              ],
            ),
          ),
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
