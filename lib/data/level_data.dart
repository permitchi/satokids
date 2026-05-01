import 'package:flutter/material.dart';

class LevelItem {
  final String name;
  final IconData icon;
  final Color? color;

  LevelItem({required this.name, required this.icon, this.color});
}

List<LevelItem> getLevelItems(int level) {
  if (level <= 3) {
    // Animals
    return [
      LevelItem(name: "Lion", icon: Icons.pets),
      LevelItem(name: "Tiger", icon: Icons.flutter_dash),
      LevelItem(name: "Elephant", icon: Icons.cruelty_free),
      LevelItem(name: "Monkey", icon: Icons.bug_report),
      LevelItem(name: "Zebra", icon: Icons.pest_control),
    ];
  } else if (level <= 6) {
    // Colors
    return [
      LevelItem(name: "Red", icon: Icons.square, color: Colors.red),
      LevelItem(name: "Blue", icon: Icons.square, color: Colors.blue),
      LevelItem(name: "Green", icon: Icons.square, color: Colors.green),
      LevelItem(name: "Yellow", icon: Icons.square, color: Colors.yellow),
      LevelItem(name: "Orange", icon: Icons.square, color: Colors.orange),
    ];
  } else if (level <= 9) {
    // Objects
    return [
      LevelItem(name: "Chair", icon: Icons.chair),
      LevelItem(name: "Table", icon: Icons.table_bar),
      LevelItem(name: "Pen", icon: Icons.edit),
      LevelItem(name: "Book", icon: Icons.book),
      LevelItem(name: "Bag", icon: Icons.shopping_bag),
    ];
  } else {
    // Level 10: Grand Challenge (Mixed items for True/False)
    return [
      LevelItem(name: "Lion", icon: Icons.pets),
      LevelItem(name: "Red", icon: Icons.square, color: Colors.red),
      LevelItem(name: "Chair", icon: Icons.chair),
      LevelItem(name: "Elephant", icon: Icons.cruelty_free),
      LevelItem(name: "Green", icon: Icons.square, color: Colors.green),
    ];
  }
}
