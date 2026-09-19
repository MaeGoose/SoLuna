import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

import 'screens/create_account_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    // Wraps the whole app in the classic in-app device toolbar — pick a
    // device from the bar it draws around your screen, no DevTools needed.
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const SoLunaApp(),
    ),
  );
}

class SoLunaApp extends StatelessWidget {
  const SoLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'SoLuna',
      debugShowCheckedModeBanner: false,
      theme: soLunaTheme,
      home: CreateAccountScreen(
        onSubmit: (details) {
          // Wire this to Supabase later — for now just prove the data
          // makes it out of the screen.
          debugPrint('Sign up: ${details.name}, ${details.email}');
        },
        onLogInTap: () {
          debugPrint('Log in tapped');
        },
      ),
    );
  }
}
