import 'package:flutter/material.dart';

import '../data/couple_dates_repository.dart';
import '../models/couple_date.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'couple_date_detail_screen.dart';

/// Screen 4 of 6 — Couple Dates overview: total saved dates + a card that
/// opens the scrollable detail list. Loads real dates from Supabase via
/// CoupleDatesRepository.
class CoupleDatesScreen extends StatefulWidget {
  const CoupleDatesScreen({super.key});

  @override
  State<CoupleDatesScreen> createState() => _CoupleDatesScreenState();
}

class _CoupleDatesScreenState extends State<CoupleDatesScreen> {
  bool _isLoading = true;
  List<CoupleDate> _dates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await CoupleDatesRepository.fetchDates();
    if (!mounted) return;
    setState(() {
      _dates = dates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Couple Dates!', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.lg),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoupleDateDetailScreen()),
                ).then((changed) {
                  if (changed == true) _load();
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.secondary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Dates Saved', style: textTheme.labelSmall),
                            Text(
                              _dates.isEmpty
                                  ? 'No dates yet'
                                  : '${_dates.length} Magical Day${_dates.length == 1 ? '' : 's'}',
                              style: textTheme.headlineSmall,
                            ),
                            if (_dates.isEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Tap Add below to save your first one.',
                                style: textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
