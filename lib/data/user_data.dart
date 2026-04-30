import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static int userPoints = 0;
  static List<int> emotionAnswers = [];
  
  // Specific counters for each emotion
  static int happyPoints = 0;
  static int neutralPoints = 0;
  static int sadPoints = 0;
  static int angryPoints = 0;
  static int excitedPoints = 0;

  /// Load points and emotion history from persistent storage
  static Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userPoints = prefs.getInt('userPoints') ?? 0;
    
    happyPoints = prefs.getInt('happyPoints') ?? 0;
    neutralPoints = prefs.getInt('neutralPoints') ?? 0;
    sadPoints = prefs.getInt('sadPoints') ?? 0;
    angryPoints = prefs.getInt('angryPoints') ?? 0;
    excitedPoints = prefs.getInt('excitedPoints') ?? 0;

    final List<String>? storedEmotions = prefs.getStringList('emotionAnswers');
    if (storedEmotions != null) {
      emotionAnswers = storedEmotions.map((e) => int.parse(e)).toList();
    }
  }

  /// Records an emotion selection and updates points based on the choice
  static Future<void> recordEmotion(int emotionIndex) async {
    emotionAnswers.add(emotionIndex);

    // Points logic based on emotion check
    switch (emotionIndex) {
      case 0: // Happy
        happyPoints += 1;
        break;
      case 1: // Neutral
        neutralPoints += 1;
        break;
      case 2: // Sad
        sadPoints += 1;
        break;
      case 3: // Angry
        angryPoints += 1;
        break;
      case 4: // Excited
        excitedPoints += 1;
        break;
    }

    await _saveToDisk();
  }

  /// Manually add points (e.g., after completing a level)
  static Future<void> addPoints(int points) async {
    userPoints += points;
    await _saveToDisk();
  }

  /// Private helper to persist data
  static Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userPoints', userPoints);
    await prefs.setInt('happyPoints', happyPoints);
    await prefs.setInt('neutralPoints', neutralPoints);
    await prefs.setInt('sadPoints', sadPoints);
    await prefs.setInt('angryPoints', angryPoints);
    await prefs.setInt('excitedPoints', excitedPoints);

    await prefs.setStringList(
      'emotionAnswers',
      emotionAnswers.map((e) => e.toString()).toList(),
    );
  }
}
