import 'package:flutter/material.dart';
import '../data/level_data.dart';

class MemoryGame extends StatefulWidget {
  final List<LevelItem> items;
  final VoidCallback onFinish;

  const MemoryGame({super.key, required this.items, required this.onFinish});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  late List<LevelItem> cards;
  late List<bool> cardFlipped;
  late List<bool> cardMatched;
  int? firstSelectedIndex;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    cards = [...widget.items, ...widget.items]..shuffle();
    cardFlipped = List.generate(cards.length, (_) => false);
    cardMatched = List.generate(cards.length, (_) => false);
  }

  void _handleTap(int index) {
    if (isProcessing || cardFlipped[index] || cardMatched[index]) return;

    setState(() => cardFlipped[index] = true);

    if (firstSelectedIndex == null) {
      firstSelectedIndex = index;
    } else {
      isProcessing = true;
      if (cards[firstSelectedIndex!].name == cards[index].name) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              cardMatched[firstSelectedIndex!] = true;
              cardMatched[index] = true;
              firstSelectedIndex = null;
              isProcessing = false;
              if (cardMatched.every((m) => m)) widget.onFinish();
            });
          }
        });
      } else {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Memory Match!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          width: 500,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              bool show = cardFlipped[index] || cardMatched[index];
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Opacity(
                  opacity: cardMatched[index] ? 0.3 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: show ? Colors.white : Colors.blue,
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: show 
                        ? Icon(cards[index].icon, size: 40, color: cards[index].color ?? Colors.blue)
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
}
