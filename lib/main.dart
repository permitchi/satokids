import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/user_data.dart';
import 'level_select.dart';
import 'setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load user data at startup
  await UserDataManager.loadUserData();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserDataManager.isSetupComplete ? const StartScreen() : const SetupScreen(),
    ));
  },
);
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SATO Kids",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('PLAY', style: TextStyle(fontSize: 24)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmotionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  int? selectedEmotion;

  void _selectEmotion(int index) {
    setState(() {
      selectedEmotion = index;
    });
    UserDataManager.recordEmotion(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _emotionButton(0, "Happy", Icons.sentiment_very_satisfied, Colors.orange),
                const SizedBox(width: 15),
                _emotionButton(1, "Neutral", Icons.sentiment_neutral, Colors.grey),
                const SizedBox(width: 15),
                _emotionButton(2, "Sad", Icons.sentiment_very_dissatisfied, Colors.blue),
                const SizedBox(width: 15),
                _emotionButton(3, "Angry", Icons.sentiment_dissatisfied, Colors.red),
                const SizedBox(width: 15),
                _emotionButton(4, "Excited", Icons.auto_awesome, Colors.purple),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: selectedEmotion == null
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LevelSelectScreen()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Continue to Games", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emotionButton(int index, String label, IconData icon, Color color) {
    bool isSelected = selectedEmotion == index;
    return GestureDetector(
      onTap: () => _selectEmotion(index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)] : [],
            ),
            child: Icon(
              icon,
              size: 50,
              color: isSelected ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
