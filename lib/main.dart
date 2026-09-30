import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_entry_screen.dart';
import 'theme/app_scroll_behavior.dart';
import 'theme/app_theme.dart';

// Flip this to true once device_preview is confirmed working again with
// the new navigation. Left off for now to isolate a widget-tree assertion
// error that appeared right after adding MainShell/IndexedStack.
const bool _useDevicePreview = true;

// Hardcoded per your call — these aren't secret in the traditional sense
// (Row Level Security is what actually protects your data, not hiding
// this key), but they DO live in your git history forever from here on.
// Copy the anon key fresh from Settings -> API -> Legacy API keys ->
// the copy icon next to "anon" "public" (don't retype it by hand).
const _supabaseUrl = 'https://iejxvebpxdgyfdxhhxkw.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imllanh2ZWJweGRneWZkeGhoeGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2MjM0ODYsImV4cCI6MjEwNjE5OTQ4Nn0.id14xs21d4Ga6mJCNaJjPZIO1Pw4PPjTPzi5DRCCapY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);

  if (_useDevicePreview) {
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const SoLunaApp(),
      ),
    );
  } else {
    runApp(const SoLunaApp());
  }
}

class SoLunaApp extends StatelessWidget {
  const SoLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: _useDevicePreview,
      locale: _useDevicePreview ? DevicePreview.locale(context) : null,
      builder: _useDevicePreview ? DevicePreview.appBuilder : null,
      title: 'SoLuna',
      debugShowCheckedModeBanner: false,
      theme: soLunaTheme,
      scrollBehavior: AppScrollBehavior(),
      home: const AuthEntryScreen(),
    );
  }
}
