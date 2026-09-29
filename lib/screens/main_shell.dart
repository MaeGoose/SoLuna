import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'add_entry_screen.dart';
import 'couple_dates_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

/// Hosts the three tab screens (Today, Dates, Settings) behind the shared
/// bottom nav. "Add" opens a form and, if something was actually saved,
/// refreshes the tabs so the new memory/date/folder shows up.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;

  // Nav index 2 ("Add") has no page of its own, so it's left out of this
  // map and handled as a pushed screen instead.
  static const _pageForNavIndex = {0: 0, 1: 1, 3: 2};

  Future<void> _handleNavTap(int index) async {
    if (index == 2) {
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AddEntryScreen()),
      );
      // Not const below on purpose — these need to be fresh widget
      // instances each rebuild so Flutter actually re-runs their build()
      // methods and picks up whatever was just added to sample_data.dart.
      // A const list here would be treated as identical to the last one
      // and silently skipped.
      if (saved == true) {
        setState(() {});
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
