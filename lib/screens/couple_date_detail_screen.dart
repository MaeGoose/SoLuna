import 'package:flutter/material.dart';

import '../data/couple_dates_repository.dart';
import '../models/couple_date.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/polaroid_photo.dart';
import '../widgets/sticky_note_tag.dart';

/// Screen 5 of 6 — every saved date as a vertically scrollable stack of
/// polaroid cards (swipe down instead of side-to-side). Pops with `true`
/// if any date was deleted here, so the overview card's count refreshes.
class CoupleDateDetailScreen extends StatefulWidget {
  const CoupleDateDetailScreen({super.key});

  @override
  State<CoupleDateDetailScreen> createState() => _CoupleDateDetailScreenState();
}

class _CoupleDateDetailScreenState extends State<CoupleDateDetailScreen> {
  bool _isLoading = true;
  bool _changed = false;
  List<CoupleDate> _dates = [];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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

  String _dateLabel(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';

  Future<void> _confirmDelete(int index) async {
    final date = _dates[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this date?'),
        content: Text('"${date.title}" will be gone for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await CoupleDatesRepository.deleteDate(date);
      if (!mounted) return;
      setState(() {
        _dates.removeAt(index);
        _changed = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t delete that. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
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
                      onPressed: () => Navigator.pop(context, _changed),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Text('Couple Dates!', style: textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _dates.isEmpty
                          ? Center(
                              child: Text('No dates saved yet.', style: textTheme.bodyMedium),
                            )
                          : ListView.separated(
                              itemCount: _dates.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
                              itemBuilder: (context, index) {
                                final date = _dates[index];
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        children: [
                                          PolaroidPhoto(
                                            caption: date.title,
                                            mediaUrl: date.mediaUrl,
                                            localBytes: date.localBytes,
                                            width: 220,
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.35),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: () => _confirmDelete(index),
                                                icon: const Icon(Icons.delete_outline, size: 18),
                                                color: Colors.white,
                                                padding: const EdgeInsets.all(6),
                                                constraints: const BoxConstraints(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(_dateLabel(date.date), style: textTheme.labelSmall),
                                      const SizedBox(height: AppSpacing.sm),
                                      if (date.tagNote.isNotEmpty) StickyNoteTag(text: date.tagNote),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
