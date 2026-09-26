import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Screen 6 of 6 — profile summary, relationship status, and account
/// fields. Log Out is a stub until real auth exists.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _statusController = TextEditingController(text: 'In love with Jeanna');
  final _emailController = TextEditingController(text: 'soluna@coupletracker.com');
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _statusController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.secondary,
                    child: Text(
                      'B',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bernardo', style: textTheme.headlineSmall),
                      Text('Together since Aug 2021', style: textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledTextField(label: 'Status', controller: _statusController),
            const SizedBox(height: AppSpacing.xl),
            Text('Change Password / Email', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'New Password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Log Out', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
