import 'package:flutter/material.dart';
import 'data/study_data.dart';
import 'data/level_data.dart';

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
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = category["name"] as String;
          final levels = category["levels"] as List<int>;

          return ExpansionTile(
            initiallyExpanded: index == 0,
            title: Text(
              categoryName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            children: levels.map((level) {
              final content = getStudyContent(level);
              return ListTile(
                title: Text("Level $level: ${content.category}"),
                subtitle: Text("${content.items.length} items to learn"),
                leading: CircleAvatar(
                  child: Text(level.toString()),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showStudyMaterial(context, level, content),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showStudyMaterial(BuildContext context, int level, StudyContent content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Level $level Study Material",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                content.instruction,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: content.items.length,
                  itemBuilder: (context, index) {
                    final item = content.items[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Icon(
                                item.icon,
                                size: 40,
                                color: item.color ?? Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
