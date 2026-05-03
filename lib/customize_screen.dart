import 'package:flutter/material.dart';
import 'package:satokids/data/user_data.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  final Map<String, List<String>> options = {
    'Hair': ['None', 'Short Black', 'Long Brown', 'Spiky Yellow', 'Curly Red'],
    'Top': ['Simple Shirt', 'Red Hoodie', 'Green Jacket', 'Blue Tank', 'Striped Tee'],
    'Pants': ['Blue Jeans', 'Black Shorts', 'Khaki Pants', 'Purple Skirt', 'Grey Sweats'],
    'Shoes': ['Sneakers', 'Boots', 'Sandals', 'Formal Shoes', 'Sport Shoes'],
    'Head Accessory': ['None', 'Baseball Cap', 'Sun Hat', 'Tiara', 'Glasses'],
  };

  final int unlockCost = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize Character"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${UserDataManager.userPoints}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;
          
          return Row(
            children: [
              // Left Side: Character Preview
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your Character",
                          style: TextStyle(
                            fontSize: (h * 0.05).clamp(18.0, 24.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.02),
                        Container(
                          width: (h * 0.45).clamp(150.0, w * 0.4),
                          height: h * 0.75,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple, width: 3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPreviewItem("Accessory", UserDataManager.selectedAccessory, h * 0.75),
                              _buildPreviewItem("Hair", UserDataManager.selectedHair, h * 0.75),
                              _buildPreviewItem("Top", UserDataManager.selectedTop, h * 0.75),
                              _buildPreviewItem("Pants", UserDataManager.selectedPants, h * 0.75),
                              _buildPreviewItem("Shoes", UserDataManager.selectedShoes, h * 0.75),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right Side: Customization Options
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Items",
                        style: TextStyle(
                          fontSize: (h * 0.06).clamp(20.0, 28.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Unlock new items for $unlockCost points each!",
                        style: TextStyle(
                          fontSize: (h * 0.035).clamp(12.0, 16.0),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      Expanded(
                        child: ListView(
                          children: options.entries.map((entry) {
                            return _buildOptionCategory(entry.key, entry.value);
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: h * 0.02),
                      SizedBox(
                        width: double.infinity,
                        height: (h * 0.12).clamp(40.0, 60.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            "Save & Exit",
                            style: TextStyle(fontSize: (h * 0.045).clamp(16.0, 20.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, double boxHeight) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: (boxHeight * 0.03).clamp(8.0, 12.0),
                    color: Colors.purple[300],
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (boxHeight * 0.05).clamp(14.0, 22.0),
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog(String title, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unlock Item?"),
          content: Text("Do you want to unlock '$itemName' for $unlockCost points?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await UserDataManager.unlockItem(itemName, unlockCost);
                if (success) {
                  setState(() {
                    _applySelection(title, itemName);
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Unlocked $itemName!")),
                    );
                  }
                } else {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Not enough points!")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              child: const Text("Unlock"),
            ),
          ],
        );
      },
    );
  }

  void _applySelection(String title, String itemName) {
    if (title == 'Hair') UserDataManager.selectedHair = itemName;
    if (title == 'Top') UserDataManager.selectedTop = itemName;
    if (title == 'Pants') UserDataManager.selectedPants = itemName;
    if (title == 'Shoes') UserDataManager.selectedShoes = itemName;
    if (title == 'Head Accessory') UserDataManager.selectedAccessory = itemName;
    UserDataManager.updateCustomization();
  }

  Widget _buildOptionCategory(String title, List<String> items) {
    String currentSelection = '';
    if (title == 'Hair') currentSelection = UserDataManager.selectedHair;
    if (title == 'Top') currentSelection = UserDataManager.selectedTop;
    if (title == 'Pants') currentSelection = UserDataManager.selectedPants;
    if (title == 'Shoes') currentSelection = UserDataManager.selectedShoes;
    if (title == 'Head Accessory') currentSelection = UserDataManager.selectedAccessory;

    final h = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: (h * 0.015).clamp(4.0, 12.0)),
          child: Text(
            title,
            style: TextStyle(
              fontSize: (h * 0.045).clamp(16.0, 20.0),
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: items.map((itemName) {
            final isUnlocked = UserDataManager.unlockedItems.contains(itemName);
            final isSelected = currentSelection == itemName;

            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUnlocked) ...[
                    const Icon(Icons.lock, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                  ],
                  Text(itemName),
                ],
              ),
              selected: isSelected,
              selectedColor: Colors.purple[100],
              onSelected: (selected) {
                if (selected) {
                  if (isUnlocked) {
                    setState(() {
                      _applySelection(title, itemName);
                    });
                  } else {
                    _showUnlockDialog(title, itemName);
                  }
                }
              },
            );
          }).toList(),
        ),
        const Divider(),
      ],
    );
  }
}
