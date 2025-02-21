import 'package:ai_hub/pages/home/community.dart';
import 'package:ai_hub/pages/news/news_page.dart';
import 'package:ai_hub/pages/prompt/prompt_library.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../login/login_page.dart';
import '../prompt/prompt_generator.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const Community(),
    const PromptGeneratorPage(),
    const PromptLibrary(),
    const NewsPage(),
    const ProfilePage(),
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.people,
    Icons.lightbulb_outline,
    Icons.library_books,
    Icons.person,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60,
        color: Theme.of(context).colorScheme.primary,
        buttonBackgroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        items: _icons.map((icon) => Icon(icon, color: Colors.white)).toList(),
        onTap: _onItemTapped,
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Community';
      case 2:
        return 'Prompt Generator';
      case 3:
        return 'Prompt Library';
      case 4:
        return 'Profile';
      default:
        return 'AI Hub';
    }
  }
}
// Keep existing HomeContent and PlaceholderPage classes
