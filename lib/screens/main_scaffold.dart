import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'creator_studio_screen.dart';
import 'activity_screen.dart';

class MainScaffold extends StatefulWidget {
  final Color primaryColor;
  final Color darkSlate;

  const MainScaffold({
    super.key,
    required this.primaryColor,
    required this.darkSlate,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -1.2,
            ),
            children: [
              TextSpan(
                text: 'Quiz',
                style: TextStyle(color: widget.primaryColor),
              ),
              TextSpan(text: 'Bum', style: TextStyle(color: widget.darkSlate)),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: widget.darkSlate),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: widget.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 20, color: widget.primaryColor),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex, 
        children: [
          DiscoverScreen(
            primaryColor: widget.primaryColor,
            darkSlate: widget.darkSlate,
          ),
          CreatorStudioScreen(
            primaryColor: widget.primaryColor,
            darkSlate: widget.darkSlate,
          ),
          ActivityScreen(
            primaryColor: widget.primaryColor,
            darkSlate: widget.darkSlate,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: widget.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Activity',
          ),
        ],
      ),
    );
  }
}
