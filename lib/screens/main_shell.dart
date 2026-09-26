import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'couple_dates_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// Hosts the three tab screens (Today, Dates, Settings) behind the shared
/// bottom nav. "Add" has no screen yet, so it's a stub snackbar instead of
/// a fourth tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;

  // Nav index 2 ("Add") has no page of its own, so it's left out of this
  // map and handled as a stub action instead.
  static const _pageForNavIndex = {0: 0, 1: 1, 3: 2};

  void _handleNavTap(int index) {
    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a memory — coming soon')),
      );
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = _pageForNavIndex[_navIndex] ?? 0;

    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: const [
          TodayScreen(),
          CoupleDatesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _handleNavTap,
      ),
    );
  }
}
