import 'package:flutter/material.dart';
import 'package:satokids/teaching_mode.dart';
import 'package:satokids/parent_screen.dart';
import 'package:satokids/study_screen.dart';
import 'package:satokids/data/user_data.dart';
import 'package:satokids/customize_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int completedLevels = 0;
  int userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    bool rewardClaimed = await UserDataManager.loadUserData();
    setState(() {
      completedLevels = prefs.getInt('completedLevels') ?? 0;
      userPoints = UserDataManager.userPoints;
    });

    if (rewardClaimed) {
      _showDailyRewardDialog();
    }
  }

  void _showDailyRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text("Daily Reward!"),
          ],
        ),
        content: const Text(
          "Welcome back! You've received 15 points for logging in today. Come back tomorrow for more rewards!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  Future<void> _completeLevel(int level) async {
    if (level >= completedLevels) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('completedLevels', level);
      
      // Award points for completing a level
      await UserDataManager.addPoints(15);
      await UserDataManager.logLevelCompletion(level);

      setState(() {
        completedLevels = level;
        userPoints = UserDataManager.userPoints;
      });
    }
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => MediaQuery(
        // Override viewInsets to zero so the dialog stays in place (under the keyboard)
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: AlertDialog(
          scrollable: true,
          title: const Text("Enter Parent PIN"),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(hintText: "4-digit PIN"),
          ),
          actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == UserDataManager.parentPin) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ParentModeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect PIN")),
                );
              }
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    ),
  );
}

  void _showLevelDialog(int level) {
    // Level 1, 4, 7... -> Game Type 1
    // Level 2, 5, 8... -> Game Type 2
    // Level 3, 6, 9... -> Game Type 3
    int gameType = level % 3;
    if (gameType == 0) gameType = 3;

    String gameName = "Mini-game $gameType";
    if (level == 10) {
      gameName = "True/False Game";
    }

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Level $level",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        gameName,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Go to Study Screen first
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyScreen(
                                    level: level,
                                    gameType: gameType,
                                  ),
                                ),
                              );
    
                              // If study screen -> game screen returns true
                              if (result == true) {
                                await _completeLevel(level);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Start Level", style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ],
                  ),
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
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (value == 1) {
                _showPinDialog();
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
            children: List.generate(10, (index) {
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


      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  "$userPoints",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomizeScreen()),
              );
            },
            backgroundColor: Colors.purple,
            child: const Icon(Icons.card_giftcard, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
