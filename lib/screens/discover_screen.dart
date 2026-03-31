import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  final Color primaryColor;
  final Color darkSlate;

  const DiscoverScreen({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
  });

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 20),
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
                _buildQuizCard(
                  title: "Flutter Widgets Pro",
                  creator: "jilo_dev",
                  plays: "1.2k",
                  rating: 4.8,
                  category: "#Dart",
                ),
                _buildQuizCard(
                  title: "Japanese N4 Kanji",
                  creator: "SenseiMura",
                  plays: "850",
                  rating: 4.9,
                  category: "#Language",
                ),
              ],
            ),
          ),
        ],
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
