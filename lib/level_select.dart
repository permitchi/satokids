import 'package:flutter/material.dart';
import 'package:satokids/teaching_mode.dart';
import 'package:satokids/parent_screen.dart';
import 'package:satokids/study_screen.dart';
import 'package:satokids/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int completedLevels = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLevels = prefs.getInt('completedLevels') ?? 0;
    });
  }

  Future<void> _completeLevel(int level) async {
    if (level >= completedLevels) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completedLevels', level);

      setState(() {
        completedLevels = level;
      });
    }
  }

    void _showLevelDialog(int level) {
    // Level 1, 4, 7... -> Game Type 1
    // Level 2, 5, 8... -> Game Type 2
    // Level 3, 6, 9... -> Game Type 3
    int gameType = level % 3;
    if (gameType == 0) gameType = 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Level $level",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Mini-game $gameType",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudyScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Study", style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            // 1. Start game and wait for result
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  level: level,
                                  gameType: gameType,
                                ),
                              ),
                            );

                            // 2. If the user finished the game (returned true)
                            if (result == true) {
                              print("DEBUG: Level $level completed! Updating state..."); // Add this
                              await _completeLevel(level);

                              // 3. Close the dialog so the user sees the updated Level Select screen
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(200, 50),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Play", style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -10,
                top: -10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 18,
                    child: Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Level Selection"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParentModeScreen()),
                );
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeachingScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Quit to Start"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Parent Mode"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.black),
                    SizedBox(width: 8),
                    Text("Teaching Screen"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: List.generate(15, (index) {
              int level = index + 1;
              bool isUnlocked = level <= completedLevels + 1;
              bool isCompleted = level <= completedLevels;

              return SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(0),
                    backgroundColor: isCompleted 
                        ? Colors.green 
                        : (isUnlocked ? Colors.blue : Colors.grey),
                  ),
                  onPressed: isUnlocked ? () => _showLevelDialog(level) : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$level",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (!isUnlocked)
                        const Icon(Icons.lock, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
