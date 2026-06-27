import 'package:flutter/material.dart';
import 'package:smart_street_light/theme_and_store.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  // පහත Navigation Bar එකෙන් මාරු විය යුතු පිටු ලැයිස්තුව
  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      
      // දැනට තෝරාගෙන ඇති පිටුව පෙන්වීම
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // පතුලේ ඇති Navigation තීරුව (Bottom Navigation Bar)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDim,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}