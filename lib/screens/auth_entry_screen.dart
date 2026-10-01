import 'package:flutter/material.dart';

import 'create_account_screen.dart';
import 'log_in_screen.dart';
import 'main_shell.dart';

/// Wraps LogInScreen — the app's actual entry point now — with what
/// happens after real auth succeeds, and wires the "create one" hop into
/// CreateAccountScreen for people who don't have an account yet. Pulled
/// out of main.dart so Settings' "Log Out" can push back to the exact
/// same place without duplicating this wiring.
class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  void _goToMainShell(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LogInScreen(
      onLogInSuccess: () => _goToMainShell(context),
      onCreateAccountTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateAccountScreen(
              onSubmit: (_) => _goToMainShell(context),
            ),
          ),
        );
      },
    );
  }
}
