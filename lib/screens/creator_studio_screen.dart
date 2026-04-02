import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'create_quiz_screen.dart';
import 'play_lobby_screen.dart';
import '../providers/quiz_provider.dart';

class CreatorStudioScreen extends ConsumerWidget {
  final Color primaryColor;
  final Color darkSlate;

  const CreatorStudioScreen({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(fetchedQuizzesProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [Tab(text: "Published"), Tab(text: "Drafts")],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildAnalyticsCard(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Create Screen, and when we come back, we refresh the list
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
                    ).then((_) {
                      ref.invalidate(fetchedQuizzesProvider);
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create New Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My Quizzes",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(fetchedQuizzesProvider),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                quizzesAsync.when(
                  data: (quizzes) {
                    if (quizzes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No quizzes published yet. Create one!",
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: quizzes.map((quiz) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayLobbyScreen(
                                  primaryColor: primaryColor,
                                  darkSlate: darkSlate,
                                  quiz: quiz,
                                ),
                              ),
                            );
                          },
                          child: _buildCreatorQuizCard(
                            quiz.title,
                            "Play now",
                            "${quiz.questions.length} questions",
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text("Error loading quizzes: $e"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Live Analytics",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            "2,451 Total Plays",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleStat("88%", "Avg. Pass Rate"),
              _buildSimpleStat("+12", "New Followers"),
              _buildSimpleStat("4.8", "Avg. Rating"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildCreatorQuizCard(String title, String plays, String passRatio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.article_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "$plays • $passRatio",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share, size: 20)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 20)),
        ],
      ),
    );
  }
}
