import 'package:flutter/material.dart';
import 'data/study_data.dart';
import 'study_screen.dart';

class TeachingScreen extends StatelessWidget {
  const TeachingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Grouping levels by category for better organization
    final categories = [
      {"name": "Animals", "levels": [1, 2, 3, 4, 5]},
      {"name": "Colors", "levels": [6, 7, 8, 9, 10]},
      {"name": "Objects", "levels": [11, 12, 13, 14, 15]},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teaching Mode"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category["name"] as String;
          final levels = category["levels"] as List<int>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              ...levels.map((level) {
                final content = getStudyContent(level);
                return ListTile(
                  title: Text("Level $level: ${content.category}"),
                  subtitle: Text("${content.items.length} items to learn"),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      level.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    int gameType = level % 3;
                    if (gameType == 0) gameType = 3;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudyScreen(
                          level: level,
                          gameType: gameType,
                          isTeachingMode: true,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
