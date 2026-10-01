import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Screen 1 — the app's actual entry point. Returning users log in here;
/// new users tap through to [CreateAccountScreen] via [onCreateAccountTap].
/// Owns its own form state and the Supabase sign-in call, same pattern
/// CreateAccountScreen already used for sign-up.
class LogInScreen extends StatefulWidget {
  const LogInScreen({
    super.key,
    required this.onLogInSuccess,
    required this.onCreateAccountTap,
  });

  /// Called after a successful log-in (Supabase session actually started).
  final VoidCallback onLogInSuccess;

  /// Called when the person taps "Create one" to go sign up instead.
  final VoidCallback onCreateAccountTap;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  String? _emailError;
  String? _passwordError;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is AuthException ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validate() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = email.isEmpty
          ? 'Enter your email.'
          : (!_emailPattern.hasMatch(email) ? 'That email doesn\'t look right.' : null);
      _passwordError = password.isEmpty ? 'Enter your password.' : null;
    });

    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleLogIn() async {
    if (!_validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isSubmitting = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      widget.onLogInSuccess();
    } catch (e) {
      if (mounted) _showError(e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: textTheme.bodyMedium),
                            GestureDetector(
                              onTap: _isSubmitting ? null : widget.onCreateAccountTap,
                              child: Text(
                                'Create one',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LabeledTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) setState(() => _emailError = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) setState(() => _passwordError = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _isSubmitting ? 'Logging in...' : 'Log in',
                    onPressed: _isSubmitting ? null : _handleLogIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
