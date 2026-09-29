import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import 'add_date_screen.dart';
import 'add_memory_screen.dart';

/// Shown when tapping "Add" in the bottom nav. Lets the person choose
/// whether they're adding a memory or a date, then hands off to the
/// matching form. Pops with `true` if either form actually saved
/// something, so MainShell knows to refresh what it's showing.
class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
              Text('Add something new', style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Add a Memory',
                onPressed: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
                  );
                  if (saved == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Add a Date',
                style: AppButtonStyle.secondary,
                onPressed: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDateScreen()),
                  );
                  if (saved == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
