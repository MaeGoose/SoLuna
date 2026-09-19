import 'package:flutter/material.dart';

import 'screens/create_account_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SoLunaApp());
}

class SoLunaApp extends StatelessWidget {
  const SoLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
