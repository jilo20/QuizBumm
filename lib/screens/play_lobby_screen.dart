import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class PlayLobbyScreen extends StatelessWidget {
  final Color primaryColor;
  final Color darkSlate;

  const PlayLobbyScreen({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  size: 80,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Flutter Architecture Master",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Created by @GoogleDevs",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat("1.2k", "Plays"),
                    const SizedBox(width: 24),
                    _buildStat("4.9", "Rating"),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Solo Mode"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.group_add),
                  label: const Text("Challenge a Friend"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Leaderboard (Top 10)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildLeaderboardItem(1, "DartVader", "2,450 pts", Colors.amber),
          _buildLeaderboardItem(
            2,
            "FlutterGuy",
            "2,380 pts",
            Colors.grey.shade400,
          ),
          _buildLeaderboardItem(
            3,
            "WidgetQueen",
            "2,100 pts",
            Colors.brown.shade300,
          ),
          _buildLeaderboardItem(4, "Skywalker", "1,950 pts", null),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String name,
    String score,
    Color? color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color ?? Colors.grey.shade100,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: color != null ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            score,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
