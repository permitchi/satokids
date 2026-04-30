import 'package:flutter/material.dart';
import 'data/user_data.dart';

class ParentModeScreen extends StatelessWidget {
  const ParentModeScreen({super.key});

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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalEmotions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Total Points", "${UserDataManager.userPoints}", Icons.stars, Colors.amber),
            Container(width: 1, height: 60, color: Colors.grey[300]),
            _buildStatItem("Check-ins", "$totalEmotions", Icons.calendar_today, Colors.blueAccent),
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
                  color: color.withOpacity(0.1),
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
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
