import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_screen.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

class PlayLobbyScreen extends ConsumerWidget {
  final Color primaryColor;
  final Color darkSlate;
  final Quiz? quiz;

  const PlayLobbyScreen({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
    this.quiz,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (quiz == null) {
      final quizzesAsync = ref.watch(fetchedQuizzesProvider);
      
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Play Modes", style: TextStyle(color: darkSlate, fontWeight: FontWeight.bold)),
          elevation: 0,
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Choose how you want to play today!",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              _buildPlayModeCard(
                title: "Quick Play",
                subtitle: "Jump into a randomly selected quiz instantly.",
                icon: Icons.shuffle,
                color: primaryColor,
                onTap: () {
                  quizzesAsync.whenData((quizzes) {
                    if (quizzes.isNotEmpty) {
                      final randomQuiz = quizzes[DateTime.now().millisecond % quizzes.length];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayLobbyScreen(
                            primaryColor: primaryColor,
                            darkSlate: darkSlate,
                            quiz: randomQuiz,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No quizzes available! Go create one first.')),
                      );
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildPlayModeCard(
                title: "Beat a Record",
                subtitle: "Enter a challenge code to compete on a friend's leaderboard.",
                icon: Icons.emoji_events,
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Challenge code entry coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildPlayModeCard(
                title: "Daily Challenge",
                subtitle: "Earn extra points with today's featured quiz.",
                icon: Icons.local_fire_department,
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daily challenges will be unlocked at Level 5!')),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: darkSlate),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                  Text(
                    quiz!.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Created on QuizBumm",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat("${quiz!.questions.length}", "Questions"),
                      const SizedBox(width: 24),
                      _buildStat("Local", "Server"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen(quiz: quiz!)),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link generated! Share it with friends to see who tops the leaderboard.')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Share to Challenge"),
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
          Expanded(
            child: Text(
              name, 
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkSlate)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

