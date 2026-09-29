import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/create_account_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';


const bool _useDevicePreview = true;

void main() {
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
      home: Builder(
        builder: (context) => CreateAccountScreen(
          onSubmit: (details) {

            debugPrint('Sign up: ${details.name}, ${details.email}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          },
          onLogInTap: () {

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainShell()),
            );
          },
        ),
      ),
    );
  }
}
