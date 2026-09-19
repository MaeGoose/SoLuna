import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Data collected on submit — kept as a plain value type so this screen
/// never has to know how the caller actually creates the account
/// (Supabase call, validation, whatever comes next).
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

/// Screen 1 of 6 — sign-up. Owns its form state locally (controllers,
/// the picked date); the only things it hands back out are callbacks,
/// so nothing here needs to know about Supabase or navigation directly.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    super.key,
    required this.onSubmit,
    required this.onLogInTap,
  });

  /// Called with the four collected fields when "Sign up" is tapped.
  final ValueChanged<NewAccountDetails> onSubmit;

  /// Called when the person taps "Log in here".
  final VoidCallback onLogInTap;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  void _handleSignUp() {
    widget.onSubmit(
      NewAccountDetails(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        dateOfBirth: _dateOfBirth,
      ),
    );
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
                            Text('Already Registered? ', style: textTheme.bodyMedium),
                            GestureDetector(
                              onTap: widget.onLogInTap,
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
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
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
                  AppButton(label: 'Sign up', onPressed: _handleSignUp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
