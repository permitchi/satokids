import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int gameType;

  const GameScreen({super.key, required this.level, required this.gameType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isGameFinished = false;

  // --- State for Matching Game (Minigame 1) ---
  IconData? selectedIcon;
  Map<IconData, String> userPairings = {};
  final List<IconData> icons = [Icons.apple, Icons.directions_car, Icons.house];
  final List<String> wordsList = ["Car", "House", "Apple"];

  // --- State for Scrambled Word Game (Minigame 2) ---
  final String targetWord = "APPLE";
  late List<String> scrambledLetters;
  List<String> userAttempt = [];
  List<int> usedIndices = [];
  int wrongAttempts = 0;
  bool hintRequested = false;

  // --- State for Memory Game (Minigame 3) ---
  late List<IconData> memoryCards;
  late List<bool> cardFlipped;
  late List<bool> cardMatched;
  int? firstSelectedIndex;
  bool isProcessing = false;
  final List<IconData> availableIcons = [
    Icons.star, Icons.favorite, Icons.anchor, Icons.alarm,
    Icons.beach_access, Icons.cloud, Icons.directions_bike, Icons.extension,
    Icons.face, Icons.home, Icons.lightbulb, Icons.movie
  ];

  @override
  void initState() {
    super.initState();
    _initScrambledGame();
    _initMemoryGame();
  }

  void _initScrambledGame() {
    scrambledLetters = targetWord.split('')..shuffle();
    userAttempt = [];
    usedIndices = [];
  }

  void _initMemoryGame() {
    // You can easily change pairsCount to increase difficulty/size
    int pairsCount = 4; 
    List<IconData> selectedIcons = availableIcons.take(pairsCount).toList();
    memoryCards = [...selectedIcons, ...selectedIcons]..shuffle();
    cardFlipped = List.generate(memoryCards.length, (_) => false);
    cardMatched = List.generate(memoryCards.length, (_) => false);
    firstSelectedIndex = null;
    isProcessing = false;
  }

  void _finishGame() {
    setState(() {
      isGameFinished = true;
    });
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Game Finished! Level Unlocked.")),
    );
  }

  void _checkMatchings() {
    bool correct = true;
    final Map<IconData, String> correctPairings = {
      Icons.apple: "Apple",
      Icons.directions_car: "Car",
      Icons.house: "House",
    };

    userPairings.forEach((icon, word) {
      if (correctPairings[icon] != word) {
        correct = false;
      }
    });

    if (userPairings.length != correctPairings.length) {
      correct = false;
    }

    if (correct) {
      _finishGame();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Try again! Some pairings are incorrect.")),
      );
      setState(() {
        userPairings.clear();
        selectedIcon = null;
      });
    }
  }

  void _checkScrambledWord() {
    String attempt = userAttempt.join('');
    if (attempt == targetWord) {
      _finishGame();
    } else {
      setState(() {
        wrongAttempts++;
        userAttempt.clear();
        usedIndices.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong! (${2 - wrongAttempts} tries left for hint)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Level ${widget.level} - Game ${widget.gameType}"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMinigameUI(),
              const SizedBox(height: 40),
              if (isGameFinished)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text("Back to Level Select", style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinigameUI() {
    switch (widget.gameType) {
      case 1:
        return _buildMatchingGame();
      case 2:
        return _buildScrambledGame();
      case 3:
        return _buildMemoryGame();
      default:
        return const Text("Unknown Game");
    }
  }

  // --- MINIGAME 1: MATCHING GAME ---
  Widget _buildMatchingGame() {
    bool allPaired = userPairings.length == icons.length;

    return Column(
      children: [
        const Text("Match the Images to the Words", 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text("Tap an icon, then tap its word", 
          style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: icons.map((icon) {
                bool isSelected = selectedIcon == icon;
                bool isPaired = userPairings.containsKey(icon);
                return GestureDetector(
                  onTap: isGameFinished ? null : () {
                    setState(() {
                      selectedIcon = icon;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPaired ? Colors.green.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : (isPaired ? Colors.green : Colors.grey),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, size: 60, color: isPaired ? Colors.green : Colors.black),
                  ),
                );
              }).toList(),
            ),
            Column(
              children: wordsList.map((word) {
                bool isPaired = userPairings.containsValue(word);
                return GestureDetector(
                  onTap: isGameFinished ? null : () {
                    if (selectedIcon != null) {
                      setState(() {
                        userPairings.remove(selectedIcon);
                        userPairings.removeWhere((k, v) => v == word);
                        userPairings[selectedIcon!] = word;
                        selectedIcon = null;
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    decoration: BoxDecoration(
                      color: isPaired ? Colors.green.withOpacity(0.1) : Colors.transparent,
                      border: Border.all(
                        color: isPaired ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: (allPaired && !isGameFinished) ? _checkMatchings : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: allPaired ? Colors.orange : Colors.grey.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text("Submit Answer", style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  // --- MINIGAME 2: SCRAMBLED WORD GAME ---
  Widget _buildScrambledGame() {
    return Column(
      children: [
        const Text("Unscramble the word!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        if (hintRequested)
          Container(
            width: 150,
            height: 150,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/150/FF0000/FFFFFF?text=APPLE'), 
                fit: BoxFit.cover,
              ),
            ),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(targetWord.length, (index) {
            String char = userAttempt.length > index ? userAttempt[index] : "";
            return Container(
              width: 45,
              height: 55,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(char, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(height: 30),

        Wrap(
          spacing: 10,
          children: scrambledLetters.asMap().entries.map((entry) {
            int idx = entry.key;
            String letter = entry.value;
            bool isUsed = usedIndices.contains(idx);
            return ElevatedButton(
              onPressed: (isGameFinished || isUsed) ? null : () {
                setState(() {
                  if (userAttempt.length < targetWord.length) {
                    userAttempt.add(letter);
                    usedIndices.add(idx);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(50, 50),
                backgroundColor: isUsed ? Colors.grey[300] : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(letter, style: TextStyle(
                fontSize: 20,
                color: isUsed ? Colors.grey : Colors.black,
              )),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                userAttempt.clear();
                usedIndices.clear();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text("Clear"),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: (userAttempt.length == targetWord.length && !isGameFinished)
                  ? _checkScrambledWord
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Check Answer"),
            ),
          ],
        ),

        if (wrongAttempts >= 2 && !hintRequested)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextButton.icon(
              onPressed: () => setState(() => hintRequested = true),
              icon: const Icon(Icons.lightbulb, color: Colors.orange),
              label: const Text("Need a hint? (Show Picture)", style: TextStyle(color: Colors.orange)),
            ),
          ),
      ],
    );
  }

  // --- MINIGAME 3: MEMORY GAME ---
  Widget _buildMemoryGame() {
    int crossAxisCount = memoryCards.length <= 8 ? 4 : 4;

    return Column(
      children: [
        const Text("Memory Match!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text("Find all the pairs", style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 20),
        SizedBox(
          width: 400, // Fixed width for the grid to keep it centered
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: memoryCards.length,
            itemBuilder: (context, index) {
              bool isFlipped = cardFlipped[index];
              bool isMatched = cardMatched[index];

              return GestureDetector(
                onTap: (isProcessing || isFlipped || isMatched || isGameFinished)
                    ? null
                    : () => _handleCardTap(index),
                child: Opacity(
                  opacity: isMatched ? 0.3 : 1.0, // "Discarded" effect
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFlipped || isMatched ? Colors.white : Colors.blue,
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        if (!isFlipped && !isMatched)
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(2, 2))
                      ],
                    ),
                    child: Center(
                      child: (isFlipped || isMatched)
                          ? Icon(memoryCards[index], size: 40, color: Colors.blue)
                          : const Icon(Icons.help_outline, size: 40, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleCardTap(int index) {
    setState(() {
      cardFlipped[index] = true;
    });

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      isProcessing = true;
      // Check for match
      if (memoryCards[firstSelectedIndex!] == memoryCards[index]) {
        // It's a match!
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              cardMatched[firstSelectedIndex!] = true;
              cardMatched[index] = true;
              firstSelectedIndex = null;
              isProcessing = false;
              
              // Check if all matched
              if (cardMatched.every((m) => m)) {
                _finishGame();
              }
            });
          }
        });
      } else {
        // Not a match, flip back
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              cardFlipped[firstSelectedIndex!] = false;
              cardFlipped[index] = false;
              firstSelectedIndex = null;
              isProcessing = false;
            });
          }
        });
      }
    }
  }
}
