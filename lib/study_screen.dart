import 'package:flutter/material.dart';
import 'data/study_data.dart';
import 'game_screen.dart';
import 'flashcard_screen.dart';

class StudyScreen extends StatelessWidget {
  final int level;
  final int gameType;
  final bool isTeachingMode;

  const StudyScreen({
    super.key,
    required this.level,
    required this.gameType,
    this.isTeachingMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = getStudyContent(level);

    return Scaffold(
      appBar: AppBar(title: Text("Study Level $level - ${content.category}")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content.instruction, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: content.items.map((item) => Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(item.icon, size: 50, color: item.color ?? Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                )).toList(),
              ),
              const SizedBox(height: 50),
              if (!isTeachingMode)
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen(level: level, gameType: gameType)),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: const Text("Start Game", style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
              if (isTeachingMode)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FlashcardScreen(level: level)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: const Text("Review Flashcards", style: TextStyle(fontSize: 22, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
