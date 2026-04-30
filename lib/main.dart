import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'level_select.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MaterialApp(
      home: StartScreen(),
    ));
  });
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Play'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmotionScreen()),
            );
          },
        ),
      ),
    );
  }
}

class EmotionScreen extends StatelessWidget {
  const EmotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Happy'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Confused'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Sad'),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Angry'),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                child: const Text('Continue'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (
                                        context) => const LevelSelectScreen()),
                                  );
                                },
                              ),
                            ]
                        )
                      ]
            )
        )
    );
  }
}