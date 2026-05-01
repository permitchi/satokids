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
      body: Row(
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
                    const Text(
                      "Your Character",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 200,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPreviewItem("Accessory", UserDataManager.selectedAccessory),
                          _buildPreviewItem("Hair", UserDataManager.selectedHair),
                          _buildPreviewItem("Top", UserDataManager.selectedTop),
                          _buildPreviewItem("Pants", UserDataManager.selectedPants),
                          _buildPreviewItem("Shoes", UserDataManager.selectedShoes),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Items",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Unlock new items for $unlockCost points each!",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: options.entries.map((entry) {
                        return _buildOptionCategory(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Save & Exit", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontWeight: FontWeight.w500),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final itemName = items[index];
              final isUnlocked = UserDataManager.unlockedItems.contains(itemName);
              final isSelected = currentSelection == itemName;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Row(
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
                ),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
