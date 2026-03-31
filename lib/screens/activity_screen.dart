import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  final Color primaryColor;
  final Color darkSlate;

  const ActivityScreen({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Social Alerts",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildNotification(
          "User123 just played your 'Flutter Basics' quiz!",
          "2m ago",
          Icons.play_arrow_rounded,
        ),
        _buildNotification(
          "Your quiz 'Dart Streams' hit 100 plays!",
          "1h ago",
          Icons.trending_up,
        ),
        _buildNotification(
          "SenseiMura just published a new quiz.",
          "3h ago",
          Icons.new_releases_outlined,
        ),
        const SizedBox(height: 32),
        const Text(
          "Following Feed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "GoogleDevs",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    "Just Now",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Check out our new quiz on Material Design 3 and Flutter 3.20! Ready to test your UI skills?",
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: primaryColor.withOpacity(0.1),
                  height: 100,
                  width: double.infinity,
                  child: const Center(
                    child: Icon(Icons.quiz, size: 40, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotification(String text, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 14)),
                Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
