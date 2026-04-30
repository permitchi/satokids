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

  if (level <= 5) {
    category = "Animals";
    instruction = "Look at these animals and remember their names!";
  } else if (level <= 10) {
    category = "Colors";
    instruction = "Let's learn these bright colors!";
  } else {
    category = "Objects";
    instruction = "These are things you can find around you!";
  }

  return StudyContent(
    category: category,
    items: items,
    instruction: instruction,
  );
}
