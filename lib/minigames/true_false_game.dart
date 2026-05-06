import 'package:flutter/material.dart';
import '../data/level_data.dart';
import 'dart:math';

class TrueFalseGame extends StatefulWidget {
  final List<LevelItem> items;
  final VoidCallback onFinish;

  const TrueFalseGame({super.key, required this.items, required this.onFinish});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> with SingleTickerProviderStateMixin {
  late LevelItem currentItem;
  late String displayedName;
  late bool isCorrectPair;
  int questionsAnswered = 0;
  final int totalQuestions = 5;
  bool _showSuccess = false;
  bool _isProcessing = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: -15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _nextQuestion();
  }

  void _nextQuestion() {
    if (questionsAnswered >= totalQuestions) {
      widget.onFinish();
      return;
    }

    setState(() {
      currentItem = widget.items[Random().nextInt(widget.items.length)];
      isCorrectPair = Random().nextBool();

      if (isCorrectPair) {
        displayedName = currentItem.name;
      } else {
        // Pick a wrong name from the list
        List<LevelItem> otherItems = widget.items.where((item) => item.name != currentItem.name).toList();
        if (otherItems.isNotEmpty) {
          displayedName = otherItems[Random().nextInt(otherItems.length)].name;
        } else {
          displayedName = "Not ${currentItem.name}";
        }
      }
    });
  }

  bool _checkAnswer(bool userGuess) {
    if (_isProcessing) return false;

    if (userGuess == isCorrectPair) {
      setState(() {
        _isProcessing = true;
        _showSuccess = true;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _isProcessing = false;
            questionsAnswered++;
          });
          _nextQuestion();
        }
      });
      return true;
    } else {
      // Wrong answer - visual feedback
      _shakeController.forward(from: 0.0);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oops! That's not right. Try again!"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(milliseconds: 700),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Question ${questionsAnswered + 1} / $totalQuestions",
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        const Text(
          "Is this correct?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 250,
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.shade100, width: 4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(currentItem.icon, size: 100, color: currentItem.color ?? Colors.blue),
                    const SizedBox(height: 20),
                    Text(
                      displayedName,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (_showSuccess)
                Container(
                  height: 250,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: Colors.white, size: 100),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _checkAnswer(false),
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text("FALSE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(width: 40),
            ElevatedButton.icon(
              onPressed: () => _checkAnswer(true),
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text("TRUE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
