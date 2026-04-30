import 'package:flutter/material.dart';
import '../data/level_data.dart';
import 'dart:math';

class ScrambledWordGame extends StatefulWidget {
  final List<LevelItem> items;
  final VoidCallback onFinish;

  const ScrambledWordGame({super.key, required this.items, required this.onFinish});

  @override
  State<ScrambledWordGame> createState() => _ScrambledWordGameState();
}

class _ScrambledWordGameState extends State<ScrambledWordGame> {
  late LevelItem targetItem;
  late List<String> scrambledLetters;
  List<String> userAttempt = [];
  List<int> usedIndices = [];
  int wrongAttempts = 0;
  bool hintRequested = false;

  @override
  void initState() {
    super.initState();
    targetItem = widget.items[Random().nextInt(widget.items.length)];
    scrambledLetters = targetItem.name.toUpperCase().split('')..shuffle();
  }

  void _checkAnswer() {
    if (userAttempt.join('') == targetItem.name.toUpperCase()) {
      widget.onFinish();
    } else {
      setState(() {
        wrongAttempts++;
        userAttempt.clear();
        usedIndices.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong! Try rescrambling again!"),
        )
      );
    }
  }

  void _undoLast() {
    if (userAttempt.isNotEmpty) {
      setState(() {
        userAttempt.removeLast();
        usedIndices.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Unscramble the word!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (hintRequested)
          Icon(targetItem.icon, size: 100, color: targetItem.color ?? Colors.blue),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(targetItem.name.length, (index) {
            String char = userAttempt.length > index ? userAttempt[index] : "";
            return Container(
              width: 45, height: 55,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2), borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Text(char, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            );
          }),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          children: scrambledLetters.asMap().entries.map((entry) {
            bool isUsed = usedIndices.contains(entry.key);
            return ElevatedButton(
              onPressed: isUsed ? null : () {
                setState(() {
                  if (userAttempt.length < targetItem.name.length) {
                    userAttempt.add(entry.value);
                    usedIndices.add(entry.key);
                  }
                });
              },
              child: Text(entry.value),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() {
                userAttempt.clear();
                usedIndices.clear();
              }),
              child: const Text("Clear"),
            ),
            const SizedBox(width: 40),
            ElevatedButton(
              onPressed: userAttempt.length == targetItem.name.length ? _checkAnswer : null,
              child: const Text("Check Answer"),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.backspace_outlined),
              onPressed: userAttempt.isNotEmpty ? _undoLast : null,
              tooltip: "Undo",
            ),
          ],
        ),
        if (wrongAttempts >= 2 && !hintRequested)
          TextButton(onPressed: () => setState(() => hintRequested = true), child: const Text("Need a hint?")),
      ],
    );
  }
}
