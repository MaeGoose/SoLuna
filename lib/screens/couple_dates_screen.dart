import 'package:flutter/material.dart';

import '../data/couple_dates_repository.dart';
import '../data/memories_repository.dart';
import '../models/couple_date.dart';
import '../models/date_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_search_field.dart';
import '../widgets/memory_photo.dart';
import 'couple_date_detail_screen.dart';

/// Screen 4 of 6 — Couple Dates overview: each category ("School Dates",
/// "Resto Dates", etc) gets its own card, banner photo pulled from one
/// of that category's dates when it has one. Loads real data from
/// Supabase via CoupleDatesRepository. Searching replaces the category
/// cards with matching dates across all categories.
class CoupleDatesScreen extends StatefulWidget {
  const CoupleDatesScreen({super.key});

  @override
  State<CoupleDatesScreen> createState() => _CoupleDatesScreenState();
}

class _CoupleDatesScreenState extends State<CoupleDatesScreen> {
  bool _isLoading = true;
  List<DateCategory> _categories = [];
  List<CoupleDate> _allDates = [];
  String _searchQuery = '';

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await CoupleDatesRepository.fetchCategories();
    final dates = await CoupleDatesRepository.fetchDates();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _allDates = dates;
      _isLoading = false;
    });
  }

  List<CoupleDate> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    return _allDates.where((d) {
      if (d.title.toLowerCase().contains(query)) return true;
      final month = _monthNames[d.date.month - 1].toLowerCase();
      final dateText = '$month ${d.date.day} ${d.date.year}';
      return dateText.contains(query);
    }).toList();
  }

  /// First photo found on any date in this category — used as the
  /// card's banner instead of the plain gradient, when one exists.
  String? _coverPhotoFor(String categoryId) {
    for (final date in _allDates) {
      if (date.categoryId == categoryId && date.photoUrls.isNotEmpty) {
        return date.photoUrls.first;
      }
    }
    return null;
  }

  int _countFor(String categoryId) => _allDates.where((d) => d.categoryId == categoryId).length;

  Future<void> _createCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. School Dates'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    try {
      final coupleId = await MemoriesRepository.getOrCreateCoupleId();
      final category = await CoupleDatesRepository.createCategory(coupleId: coupleId, title: name);
      if (!mounted) return;
      setState(() => _categories = [..._categories, category]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t create that category.')),
      );
    }
  }

  Widget _emptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPink),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: textTheme.labelSmall, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action,
          ],
        ],
      ),
    );
  }

  Widget _categoryCard(DateCategory category) {
    final textTheme = Theme.of(context).textTheme;
    final cover = _coverPhotoFor(category.id);
    final count = _countFor(category.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoupleDateDetailScreen(category: category)),
      ).then((changed) {
        if (changed == true) _load();
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
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
            SizedBox(
              height: 160,
              width: double.infinity,
              child: cover != null
                  ? MemoryPhoto(mediaUrl: cover)
                  : const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    count == 0 ? 'No dates yet' : '$count Magical Day${count == 1 ? '' : 's'}',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResultRow(CoupleDate date) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CoupleDateDetailScreen(searchQuery: _searchQuery.trim()),
        ),
      ).then((changed) {
        if (changed == true) _load();
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderPink),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: MemoryPhoto(
                mediaUrl: date.photoUrls.isNotEmpty ? date.photoUrls.first : null,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date.title, style: textTheme.bodyMedium),
                  Text(
                    '${_monthNames[date.date.month - 1].substring(0, 3)} ${date.date.day}, ${date.date.year}',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSearching = _searchQuery.trim().isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Couple Dates!', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.md),
            AppSearchField(
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isSearching) ...[
              Text('Search results', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              if (_searchResults.isEmpty)
                _emptyStateCard(
                  icon: Icons.search_off,
                  title: 'No dates match "${_searchQuery.trim()}"',
                  subtitle: 'Try a different title or date.',
                )
              else
                for (final date in _searchResults) _searchResultRow(date),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: textTheme.headlineSmall),
                  IconButton(
                    onPressed: _createCategory,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add a category',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_categories.isEmpty)
                _emptyStateCard(
                  icon: Icons.folder_open_outlined,
                  title: 'No categories yet',
                  subtitle: 'Press the button below to add your first one, like "School Dates".',
                  action: AppButton(
                    label: 'Add a Category',
                    style: AppButtonStyle.secondary,
                    onPressed: _createCategory,
                  ),
                )
              else
                for (final category in _categories) _categoryCard(category),
            ],
          ],
        ),
      ),
    );
  }
}
