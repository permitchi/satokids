import 'package:flutter/material.dart';
import '../data/level_data.dart';

class MatchingGame extends StatefulWidget {
  final List<LevelItem> items;
  final VoidCallback onFinish;

  const MatchingGame({super.key, required this.items, required this.onFinish});

  @override
  State<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  LevelItem? selectedItem;
  Map<LevelItem, LevelItem> userPairings = {};
  final GlobalKey _stackKey = GlobalKey();
  final Map<LevelItem, GlobalKey> iconKeys = {};
  final Map<LevelItem, GlobalKey> wordKeys = {};

  late List<LevelItem> shuffledIcons;
  late List<LevelItem> shuffledWords;

  @override
  void initState() {
    super.initState();
    shuffledIcons = List.from(widget.items)..shuffle();
    shuffledWords = List.from(widget.items)..shuffle();
    for (var item in widget.items) {
      iconKeys[item] = GlobalKey();
      wordKeys[item] = GlobalKey();
    }
  }

  void _checkMatchings() {
    if (userPairings.length == widget.items.length) {
      widget.onFinish();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match all items first!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Match the Images to the Words", 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Stack(
          key: _stackKey,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ConnectionPainter(
                  userPairings,
                  iconKeys,
                  wordKeys,
                  _stackKey,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: shuffledIcons.map((item) {
                    bool isSelected = selectedItem == item;
                    bool isPaired = userPairings.containsKey(item);
                    return GestureDetector(
                      key: iconKeys[item],
                      onTap: () => setState(() => selectedItem = item),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPaired ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue : (isPaired ? Colors.green : Colors.grey),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(item.icon, size: 60, color: item.color ?? (isPaired ? Colors.green : Colors.black)),
                      ),
                    );
                  }).toList(),
                ),
                Column(
                  children: shuffledWords.map((item) {
                    bool isPaired = userPairings.containsValue(item);
                    return GestureDetector(
                      key: wordKeys[item],
                      onTap: () {
                        if (selectedItem != null) {
                          setState(() {
                            userPairings.remove(selectedItem);
                            userPairings.removeWhere((k, v) => v == item);
                            userPairings[selectedItem!] = item;
                            selectedItem = null;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                        decoration: BoxDecoration(
                          color: isPaired ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                          border: Border.all(
                            color: isPaired ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _checkMatchings,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Submit Answer", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Map<LevelItem, LevelItem> pairings;
  final Map<LevelItem, GlobalKey> iconKeys;
  final Map<LevelItem, GlobalKey> wordKeys;
  final GlobalKey parentKey;

  ConnectionPainter(this.pairings, this.iconKeys, this.wordKeys, this.parentKey);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..strokeWidth = 3;
    final RenderBox? parentBox = parentKey.currentContext?.findRenderObject() as RenderBox?;
    if (parentBox == null) return;

    pairings.forEach((iconItem, wordItem) {
      final RenderBox? iconBox = iconKeys[iconItem]?.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? wordBox = wordKeys[wordItem]?.currentContext?.findRenderObject() as RenderBox?;

      if (iconBox != null && wordBox != null) {
        final iconPos = parentBox.globalToLocal(iconBox.localToGlobal(Offset(iconBox.size.width - 15, iconBox.size.height / 2)));
        final wordPos = parentBox.globalToLocal(wordBox.localToGlobal(Offset(15, wordBox.size.height / 2)));
        canvas.drawLine(iconPos, wordPos, paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
