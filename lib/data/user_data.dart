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

  static int totalPlayTimeSeconds = 0;
  static int totalSessions = 0;
  static String lastLoginDate = '';
  
  // Weekly Logs
  static List<int> weeklyCompletedLevels = [];
  static List<String> weeklyBoughtItems = [];
  static int lastResetTimestamp = 0;

  // Character customization
  static String selectedHair = 'None';
  static String selectedTop = 'Simple Shirt';
  static String selectedPants = 'Blue Jeans';
  static String selectedShoes = 'Sneakers';
  static String selectedAccessory = 'None';
  static Set<String> unlockedItems = {'None', 'Simple Shirt', 'Blue Jeans', 'Sneakers'};

  static bool isSetupComplete = false;
  static String parentPin = '0000';
  static bool emotionRecordedThisSession = false;
  static bool dailyRewardClaimed = false;

  /// Load points and emotion history from persistent storage.
  /// Returns true if a daily login reward was claimed.
  static Future<bool> loadUserData({bool awardDailyPoints = true}) async {
    final prefs = await SharedPreferences.getInstance();
    userPoints = prefs.getInt('userPoints') ?? 0;
    
    happyPoints = prefs.getInt('happyPoints') ?? 0;
    neutralPoints = prefs.getInt('neutralPoints') ?? 0;
    sadPoints = prefs.getInt('sadPoints') ?? 0;
    angryPoints = prefs.getInt('angryPoints') ?? 0;
    excitedPoints = prefs.getInt('excitedPoints') ?? 0;

    totalPlayTimeSeconds = prefs.getInt('totalPlayTimeSeconds') ?? 0;
    totalSessions = prefs.getInt('totalSessions') ?? 0;
    lastLoginDate = prefs.getString('lastLoginDate') ?? '';
    lastResetTimestamp = prefs.getInt('lastResetTimestamp') ?? 0;

    isSetupComplete = prefs.getBool('isSetupComplete') ?? false;
    parentPin = prefs.getString('parentPin') ?? '0000';

    // Check for Weekly Reset (7 days = 604800000 ms)
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastResetTimestamp > 604800000) {
      weeklyCompletedLevels = [];
      weeklyBoughtItems = [];
      lastResetTimestamp = now;
      await _saveToDisk();
    } else {
      weeklyCompletedLevels = (prefs.getStringList('weeklyCompletedLevels') ?? []).map(int.parse).toList();
      weeklyBoughtItems = prefs.getStringList('weeklyBoughtItems') ?? [];
    }

    // Check for Daily Login Reward
    String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD
    if (lastLoginDate != today) {
      if (awardDailyPoints) {
        userPoints += 15;
        dailyRewardClaimed = true; // Set to true if it's a new day
      }
      lastLoginDate = today;
      dailyRewardClaimed = true;
      await _saveToDisk();
    }

    selectedHair = prefs.getString('selectedHair') ?? 'None';
    selectedTop = prefs.getString('selectedTop') ?? 'Simple Shirt';
    selectedPants = prefs.getString('selectedPants') ?? 'Blue Jeans';
    selectedShoes = prefs.getString('selectedShoes') ?? 'Sneakers';
    selectedAccessory = prefs.getString('selectedAccessory') ?? 'None';

    final List<String>? unlockedList = prefs.getStringList('unlockedItems');
    if (unlockedList != null) {
      unlockedItems = unlockedList.toSet();
    } else {
      unlockedItems = {'None', 'Simple Shirt', 'Blue Jeans', 'Sneakers'};
    }

    final List<String>? storedEmotions = prefs.getStringList('emotionAnswers');
    if (storedEmotions != null) {
      emotionAnswers = storedEmotions.map((e) => int.parse(e)).toList();
    }

    return dailyRewardClaimed;
  }

  /// Records an emotion selection and updates points based on the choice
  static Future<void> recordEmotion(int emotionIndex) async {
    emotionAnswers.add(emotionIndex);
    emotionRecordedThisSession = true;

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
    await prefs.setBool('isSetupComplete', isSetupComplete);
    await prefs.setString('parentPin', parentPin);
    await prefs.setInt('userPoints', userPoints);
    await prefs.setInt('happyPoints', happyPoints);
    await prefs.setInt('neutralPoints', neutralPoints);
    await prefs.setInt('sadPoints', sadPoints);
    await prefs.setInt('angryPoints', angryPoints);
    await prefs.setInt('excitedPoints', excitedPoints);
    await prefs.setInt('totalPlayTimeSeconds', totalPlayTimeSeconds);
    await prefs.setInt('totalSessions', totalSessions);
    await prefs.setString('lastLoginDate', lastLoginDate);
    await prefs.setInt('lastResetTimestamp', lastResetTimestamp);
    await prefs.setStringList('weeklyCompletedLevels', weeklyCompletedLevels.map((e) => e.toString()).toList());
    await prefs.setStringList('weeklyBoughtItems', weeklyBoughtItems);

    await prefs.setString('selectedHair', selectedHair);
    await prefs.setString('selectedTop', selectedTop);
    await prefs.setString('selectedPants', selectedPants);
    await prefs.setString('selectedShoes', selectedShoes);
    await prefs.setString('selectedAccessory', selectedAccessory);
    await prefs.setStringList('unlockedItems', unlockedItems.toList());

    await prefs.setStringList(
      'emotionAnswers',
      emotionAnswers.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> recordSession(int seconds) async {
    totalSessions += 1;
    totalPlayTimeSeconds += seconds;
    await _saveToDisk();
  }

  static Future<void> updateCustomization({
    String? hair,
    String? top,
    String? pants,
    String? shoes,
    String? accessory,
  }) async {
    if (hair != null) selectedHair = hair;
    if (top != null) selectedTop = top;
    if (pants != null) selectedPants = pants;
    if (shoes != null) selectedShoes = shoes;
    if (accessory != null) selectedAccessory = accessory;
    await _saveToDisk();
  }

  static Future<bool> unlockItem(String itemName, int cost) async {
    if (userPoints >= cost) {
      userPoints -= cost;
      unlockedItems.add(itemName);
      if (!weeklyBoughtItems.contains(itemName)) {
        weeklyBoughtItems.add(itemName);
      }
      await _saveToDisk();
      return true;
    }
    return false;
  }

  static Future<void> completeSetup(String pin) async {
    isSetupComplete = true;
    parentPin = pin;
    await _saveToDisk();
  }

  static Future<void> updatePin(String newPin) async {
    parentPin = newPin;
    await _saveToDisk();
  }

  static Future<void> logLevelCompletion(int level) async {
    if (!weeklyCompletedLevels.contains(level)) {
      weeklyCompletedLevels.add(level);
      await _saveToDisk();
    }
  }
}
