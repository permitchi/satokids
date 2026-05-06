import 'package:flutter/material.dart';
import 'data/study_data.dart';
import 'study_screen.dart';

class TeachingScreen extends StatelessWidget {
  const TeachingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defined the 4 main categories for Teaching Mode
    final categories = [
      {
        "name": "Animals",
        "icon": Icons.pets,
        "color": Colors.orange,
        "levels": [1, 2, 3]
      },
      {
        "name": "Colors",
        "icon": Icons.palette,
        "color": Colors.blue,
        "levels": [4, 5, 6]
      },
      {
        "name": "Objects",
        "icon": Icons.category,
        "color": Colors.green,
        "levels": [7, 8, 9]
      },
      {
        "name": "Grand Challenge",
        "icon": Icons.star,
        "color": Colors.purple,
        "levels": [10]
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Main List Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final String name = category["name"] as String;
                final IconData icon = category["icon"] as IconData;
                final Color color = category["color"] as Color;
                final List<int> levels = category["levels"] as List<int>;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showLevelSelection(context, name, levels),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, size: 40, color: color),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${levels.length} Levels Available",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              padding: const EdgeInsets.only(top: 40),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      "Teaching Mode",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent[700],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLevelSelection(BuildContext context, String categoryName, List<int> levels) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Select $categoryName Level"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: levels.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final level = levels[index];
              final content = getStudyContent(level);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    "$level",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
                title: Text("Level $level"),
                subtitle: Text("${content.items.length} items to review"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context); // Close dialog
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
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
