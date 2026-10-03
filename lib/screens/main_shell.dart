import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'add_entry_screen.dart';
import 'couple_dates_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// Hosts the three tab screens (Today, Dates, Settings) behind the shared
/// bottom nav. "Add" opens a form and, if something was actually saved,
/// bumps _refreshTick so Today remounts (fresh key) and re-fetches from
/// Supabase — an IndexedStack keeps old State objects alive otherwise, so
/// a plain setState() alone wouldn't re-run TodayScreen's initState().
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  int _refreshTick = 0;

  // Nav index 2 ("Add") has no page of its own, so it's left out of this
  // map and handled as a pushed screen instead.
  static const _pageForNavIndex = {0: 0, 1: 1, 3: 2};

  Future<void> _handleNavTap(int index) async {
    if (index == 2) {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AddEntryScreen()),
      );
      if (saved == true) {
        setState(() => _refreshTick++);
      }
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
        children: [
          TodayScreen(
            key: ValueKey('today-$_refreshTick'),
            onOpenSettings: () => setState(() => _navIndex = 3),
          ),
          CoupleDatesScreen(key: ValueKey('dates-$_refreshTick')),
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
