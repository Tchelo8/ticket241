
import 'package:flutter/material.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/tickets_screen.dart';
import 'package:myapp/profile_screen.dart';
import 'package:myapp/explorer_screen.dart';
import 'package:myapp/favorites_screen.dart'; // Import the new screen
import 'package:myapp/widgets/app_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigate: _onTabTapped),
      const ExplorerScreen(),
      const FavoritesScreen(),
      TicketsScreen(onNavigate: _onTabTapped),
      ProfileScreen(onTabSelected: _onTabTapped), // Pass the callback
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
