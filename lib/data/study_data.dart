import 'level_data.dart';

class StudyContent {
  final String category;
  final List<LevelItem> items;
  final String instruction;

  StudyContent({
    required this.category,
    required this.items,
    required this.instruction,
  });
}

StudyContent getStudyContent(int level) {
  final items = getLevelItems(level);
  String category;
  String instruction;

  if (level <= 3) {
    category = "Animals";
    instruction = "Look at these animals and remember their names!";
  } else if (level <= 6) {
    category = "Colors";
    instruction = "Let's learn these bright colors!";
  } else if (level <= 9) {
    category = "Objects";
    instruction = "These are things you can find around you!";
  } else {
    category = "Grand Challenge";
    instruction = "Show what you've learned in the final test!";
  }

  return StudyContent(
    category: category,
    items: items,
    instruction: instruction,
  );
}
