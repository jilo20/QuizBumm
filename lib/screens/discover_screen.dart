import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'play_lobby_screen.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_models.dart';

class DiscoverScreen extends ConsumerWidget {
  final Color primaryColor;
  final Color darkSlate;

  const DiscoverScreen({
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
              tabs: const [Tab(text: "Trending"), Tab(text: "Just Published")],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(context, quizzesAsync),
                const SizedBox(height: 24),
                const Text(
                  "Browse Categories",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _buildCategoryChips(),
                const SizedBox(height: 24),
                const Text(
                  "Most Played this Week",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                quizzesAsync.when(
                  data: (quizzes) {
                    if (quizzes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "No quizzes published yet.",
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
                          child: _buildQuizCard(
                            title: quiz.title,
                            creator: "Local User",
                            plays: "${quiz.questions.length} questions",
                            rating: 5.0,
                            category: "#Custom",
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text("Error loading quizzes: $e"),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Recently Played Quizzes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                quizzesAsync.when(
                  data: (quizzes) {
                    if (quizzes.isEmpty) return const SizedBox.shrink();
                    final recentQuizzes = quizzes.reversed.take(3).toList();
                    return Column(
                      children: recentQuizzes.map((quiz) {
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
                          child: _buildQuizCard(
                            title: quiz.title,
                            creator: "Local User",
                            plays: "Played recently",
                            rating: 4.8,
                            category: "#Recent",
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AsyncValue<List<Quiz>> quizzesAsync) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context: context,
            title: "Quick Play",
            icon: Icons.shuffle,
            color: primaryColor,
            onTap: () {
              quizzesAsync.whenData((quizzes) {
                if (quizzes.isNotEmpty) {
                  final randomQuiz = quizzes[DateTime.now().millisecond % quizzes.length];
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PlayLobbyScreen(primaryColor: primaryColor, darkSlate: darkSlate, quiz: randomQuiz)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No quizzes available!')));
                }
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context: context,
            title: "Beat Record",
            icon: Icons.emoji_events,
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter challenge code coming soon!')));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: darkSlate, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Enter Quiz Code (e.g. 55621)",
          border: InputBorder.none,
          icon: Icon(Icons.qr_code_scanner, size: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      "#Dart",
      "#Flutter",
      "#JapaneseN4",
      "#History",
      "#PopCulture",
      "#Science",
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories
                .map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(cat),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade200),
                      onPressed: () {},
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildQuizCard({
    required String title,
    required String creator,
    required String plays,
    required double rating,
    required String category,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: darkSlate,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(creator, style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              const Icon(
                Icons.play_arrow_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text("$plays plays", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
