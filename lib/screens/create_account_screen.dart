import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Data collected on a successful sign-up — kept as a plain value type so
/// callers don't have to know this screen talks to Supabase internally.
class NewAccountDetails {
  const NewAccountDetails({
    required this.name,
    required this.email,
    required this.password,
    required this.dateOfBirth,
  });

  final String name;
  final String email;
  final String password;
  final DateTime? dateOfBirth;
}

/// Reached from LogInScreen via "Create one". Owns its form state
/// locally, including validation, and also owns the actual Supabase
/// auth calls, since that's inherently screen-specific work, not
/// something worth routing through a caller-supplied callback.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    super.key,
    required this.onSubmit,
  });

  /// Called after a successful sign-up (Supabase account actually created
  /// AND the profile row saved).
  final ValueChanged<NewAccountDetails> onSubmit;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _isSubmitting = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const _minPasswordLength = 6;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked == null) return;

    setState(() {
      _dateOfBirth = picked;
      _dobController.text =
          '${picked.month.toString().padLeft(2, '0')} / '
          '${picked.day.toString().padLeft(2, '0')} / '
          '${picked.year}';
    });
  }

  void _showError(Object error) {
    final message = error is AuthException ? error.message : error.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Validates the full sign-up form and populates the inline field
  /// errors. Returns whether it's actually safe to submit.
  bool _validateSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Enter your name.' : null;
      _emailError = email.isEmpty
          ? 'Enter your email.'
          : (!_emailPattern.hasMatch(email) ? 'That email doesn\'t look right.' : null);
      _passwordError = password.isEmpty
          ? 'Enter a password.'
          : (password.length < _minPasswordLength
              ? 'At least $_minPasswordLength characters.'
              : null);
      _confirmPasswordError = confirmPassword != password ? 'Passwords don\'t match.' : null;
    });

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _handleSignUp() async {
    if (!_validateSignUp()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isSubmitting = true);
    try {
      // name/date_of_birth ride along as user metadata. A Postgres trigger
      // (see profiles table setup) copies them into public.profiles as
      // soon as the auth.users row exists — so this works whether or not
      // "Confirm email" is on, without this screen needing its own
      // authenticated session to write the profile row itself.
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': _nameController.text.trim(),
          if (_dateOfBirth != null) 'date_of_birth': _dateOfBirth!.toIso8601String(),
        },
      );
      if (!mounted) return;
      widget.onSubmit(
        NewAccountDetails(
          name: _nameController.text.trim(),
          email: email,
          password: password,
          dateOfBirth: _dateOfBirth,
        ),
      );
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
          // On a phone this ConstrainedBox never kicks in — the screen is
          // already narrower than 480. On a wide browser window it stops
          // the form from stretching edge to edge, and Center pulls the
          // whole capped block into the middle of the page.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + "already registered" line are centered on
                  // their own; everything below (the form) stays
                  // left-aligned, so only this pair needs its own
                  // centered Column instead of changing the whole form.
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Create New Account',
                          style: textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text('Already registered? ', style: textTheme.bodyMedium),
                            GestureDetector(
                              onTap: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(
                                'Log in here',
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
                    label: 'Name',
                    controller: _nameController,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.md),
                  LabeledTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    errorText: _confirmPasswordError,
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledTextField(
                    label: 'Date of Birth',
                    controller: _dobController,
                    readOnly: true,
                    onTap: _pickDateOfBirth,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _isSubmitting ? 'Signing up...' : 'Sign up',
                    onPressed: _isSubmitting ? null : _handleSignUp,
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
