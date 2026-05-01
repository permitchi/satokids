import 'package:flutter/material.dart';
import 'data/user_data.dart';

class ParentModeScreen extends StatefulWidget {
  const ParentModeScreen({super.key});

  @override
  State<ParentModeScreen> createState() => _ParentModeScreenState();
}

class _ParentModeScreenState extends State<ParentModeScreen> {
  void _showResetPinDialog() {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    bool isOldPinVerified = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isOldPinVerified ? "Set New PIN" : "Verify Old PIN"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOldPinVerified)
                    TextField(
                      controller: oldPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Current PIN"),
                    )
                  else ...[
                    TextField(
                      controller: newPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "New PIN"),
                    ),
                    TextField(
                      controller: confirmPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Confirm New PIN"),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!isOldPinVerified) {
                      if (oldPinController.text == UserDataManager.parentPin) {
                        setDialogState(() {
                          isOldPinVerified = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Incorrect current PIN")),
                        );
                      }
                    } else {
                      if (newPinController.text.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN must be 4 digits")),
                        );
                      } else if (newPinController.text != confirmPinController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PINs do not match")),
                        );
                      } else {
                        UserDataManager.updatePin(newPinController.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PIN updated successfully")),
                        );
                      }
                    }
                  },
                  child: Text(isOldPinVerified ? "Update PIN" : "Verify"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total for percentage distribution
    int total = UserDataManager.happyPoints +
        UserDataManager.neutralPoints +
        UserDataManager.sadPoints +
        UserDataManager.angryPoints +
        UserDataManager.excitedPoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: _showResetPinDialog,
            tooltip: "Reset PIN",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Card
            _buildSummaryCard(total),
            const SizedBox(height: 32),
            
            const Text(
              "How has your child been feeling?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Emotion distribution based on $total check-ins",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            // Emotion Progress Bars
            _buildEmotionBar(
              label: "Happy",
              count: UserDataManager.happyPoints,
              total: total,
              color: Colors.orange,
              icon: Icons.sentiment_very_satisfied,
            ),
            _buildEmotionBar(
              label: "Excited",
              count: UserDataManager.excitedPoints,
              total: total,
              color: Colors.purple,
              icon: Icons.auto_awesome,
            ),
            _buildEmotionBar(
              label: "Neutral",
              count: UserDataManager.neutralPoints,
              total: total,
              color: Colors.blueGrey,
              icon: Icons.sentiment_neutral,
            ),
            _buildEmotionBar(
              label: "Sad",
              count: UserDataManager.sadPoints,
              total: total,
              color: Colors.blue,
              icon: Icons.sentiment_very_dissatisfied,
            ),
            _buildEmotionBar(
              label: "Angry",
              count: UserDataManager.angryPoints,
              total: total,
              color: Colors.red,
              icon: Icons.sentiment_dissatisfied,
            ),
            const SizedBox(height: 40),
            
            const Text(
              "Weekly Activity Log",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Progress and unlocks reset every 7 days.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            _buildLogSection(
              title: "Levels Completed this Week",
              icon: Icons.map,
              color: Colors.green,
              items: UserDataManager.weeklyCompletedLevels.isEmpty 
                  ? ["No levels completed yet"] 
                  : UserDataManager.weeklyCompletedLevels.map((l) => "Level $l").toList(),
            ),
            _buildLogSection(
              title: "Items Bought this Week",
              icon: Icons.shopping_bag,
              color: Colors.purple,
              items: UserDataManager.weeklyBoughtItems.isEmpty 
                  ? ["No items purchased"] 
                  : UserDataManager.weeklyBoughtItems,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(item, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalEmotions) {
    double avgPlaytimeMinutes = UserDataManager.totalSessions > 0 
        ? (UserDataManager.totalPlayTimeSeconds / UserDataManager.totalSessions) / 60 
        : 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Points", "${UserDataManager.userPoints}", Icons.stars, Colors.amber),
            _buildStatItem("Check-ins", "$totalEmotions", Icons.calendar_today, Colors.blueAccent),
            _buildStatItem("Avg Time", "${avgPlaytimeMinutes.toStringAsFixed(1)}m", Icons.timer, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildEmotionBar({
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    double percentage = total > 0 ? (count / total) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                "$count",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                " (${(percentage * 100).toStringAsFixed(0)}%)",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
