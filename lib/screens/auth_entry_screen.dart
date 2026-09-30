import 'package:flutter/material.dart';

import 'create_account_screen.dart';
import 'main_shell.dart';

/// Wraps CreateAccountScreen with what happens after real auth succeeds.
/// Pulled out of main.dart so Settings' "Log Out" can push back to the
/// exact same place without duplicating this wiring.
class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CreateAccountScreen(
      onSubmit: (_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      },
      onLogInTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      },
    );
  }
}
