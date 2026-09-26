import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

import 'screens/create_account_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

// Flip this to true once device_preview is confirmed working again with
// the new navigation. Left off for now to isolate a widget-tree assertion
// error that appeared right after adding MainShell/IndexedStack.
const bool _useDevicePreview = true;

void main() {
  if (_useDevicePreview) {
    runApp(
      DevicePreview(
        enabled: !kReleaseMode,
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
      home: Builder(
        builder: (context) => CreateAccountScreen(
          onSubmit: (details) {
            // Wire this to Supabase later — for now just prove the data
            // makes it out of the screen, then drop into the app on
            // sample data.
            debugPrint('Sign up: ${details.name}, ${details.email}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          },
          onLogInTap: () {
            // No real accounts yet, so "log in" just goes to the same
            // sample-data app for now.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          },
        ),
      ),
    );
  }
}
