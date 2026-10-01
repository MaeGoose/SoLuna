import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_entry_screen.dart';
import 'theme/app_scroll_behavior.dart';
import 'theme/app_theme.dart';

const bool _useDevicePreview = true;

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
