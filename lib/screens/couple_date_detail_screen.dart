import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/couple_dates_repository.dart';
import '../models/couple_date.dart';
import '../models/date_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/polaroid_photo.dart';
import '../widgets/sticky_note_tag.dart';

/// Screen 5 of 6 — a vertically scrollable stack of dates (swipe down
/// instead of side-to-side). Each date can show several photos, in
/// their own horizontal row, with a tile at the end to add more.
///
/// Shows one of two sets, depending on what it's opened with:
/// - [category] given: just that category's dates (plus a "delete
///   category" action — dates inside become uncategorized, not deleted).
/// - [searchQuery] given instead: every date matching that search,
///   across all categories, same title/date matching as Today's search.
///
/// Pops with `true` if anything was deleted or added here, so whichever
/// screen opened this refreshes its counts/covers.
class CoupleDateDetailScreen extends StatefulWidget {
  const CoupleDateDetailScreen({super.key, this.category, this.searchQuery})
      : assert(
          category != null || searchQuery != null,
          'Give either a category or a searchQuery',
        );

  final DateCategory? category;
  final String? searchQuery;

  @override
  State<CoupleDateDetailScreen> createState() => _CoupleDateDetailScreenState();
}

class _CoupleDateDetailScreenState extends State<CoupleDateDetailScreen> {
  final _picker = ImagePicker();
  bool _isLoading = true;
  bool _isDeletingCategory = false;
  bool _changed = false;
  List<CoupleDate> _dates = [];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _monthNamesFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String get _title => widget.category?.title ?? 'Search results';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<CoupleDate> dates;
    if (widget.category != null) {
      dates = await CoupleDatesRepository.fetchDates(categoryId: widget.category!.id);
    } else {
      final all = await CoupleDatesRepository.fetchDates();
      final query = widget.searchQuery!.trim().toLowerCase();
      dates = all.where((d) {
        if (d.title.toLowerCase().contains(query)) return true;
        final month = _monthNamesFull[d.date.month - 1].toLowerCase();
        final dateText = '$month ${d.date.day} ${d.date.year}';
        return dateText.contains(query);
      }).toList();
    }
    if (!mounted) return;
    setState(() {
      _dates = dates;
      _isLoading = false;
    });
  }

  Future<void> _confirmDeleteCategory() async {
    final category = widget.category;
    if (category == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this category?'),
        content: Text(
          _dates.isEmpty
              ? '"${category.title}" will be gone for good.'
              : '"${category.title}" will be gone for good. The ${_dates.length} '
                  '${_dates.length == 1 ? 'date' : 'dates'} inside stay saved, just uncategorized.',
        ),
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

    setState(() => _isDeletingCategory = true);
    try {
      await CoupleDatesRepository.deleteCategory(category.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingCategory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t delete that category. Try again.')),
      );
    }
  }

  String _dateLabel(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';

  Future<void> _addPhoto(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();

    try {
      final url = await CoupleDatesRepository.addPhotoToDate(
        dateId: _dates[index].id,
        photoBytes: bytes,
      );
      if (!mounted) return;
      setState(() {
        _dates[index] = _dates[index].copyWith(photoUrls: [..._dates[index].photoUrls, url]);
        _changed = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t add that photo. Try again.')),
      );
    }
  }

  Future<void> _removePhoto(int dateIndex, String photoUrl) async {
    final date = _dates[dateIndex];
    try {
      await CoupleDatesRepository.deletePhoto(dateId: date.id, mediaUrl: photoUrl);
      if (!mounted) return;
      setState(() {
        _dates[dateIndex] = date.copyWith(
          photoUrls: date.photoUrls.where((u) => u != photoUrl).toList(),
        );
        _changed = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t remove that photo. Try again.')),
      );
    }
  }

  Future<void> _confirmDeleteDate(int index) async {
    final date = _dates[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this date?'),
        content: Text('"${date.title}" and its photos will be gone for good.'),
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
                    const Spacer(),
                    if (widget.category != null)
                      IconButton(
                        onPressed: _isDeletingCategory ? null : _confirmDeleteCategory,
                        icon: _isDeletingCategory
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Delete category',
                      ),
                  ],
                ),
                Text(_title, style: textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _dates.isEmpty
                          ? Center(
                              child: Text(
                                widget.category != null
                                    ? 'No dates in this category yet.'
                                    : 'No dates match that search.',
                                style: textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              itemCount: _dates.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
                              itemBuilder: (context, index) => _DateEntry(
                                date: _dates[index],
                                dateLabel: _dateLabel(_dates[index].date),
                                onAddPhoto: () => _addPhoto(index),
                                onRemovePhoto: (url) => _removePhoto(index, url),
                                onDeleteDate: () => _confirmDeleteDate(index),
                              ),
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

class _DateEntry extends StatelessWidget {
  const _DateEntry({
    required this.date,
    required this.dateLabel,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onDeleteDate,
  });

  final CoupleDate date;
  final String dateLabel;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemovePhoto;
  final VoidCallback onDeleteDate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final url in date.photoUrls) ...[
                _DeletablePolaroid(
                  caption: date.title,
                  mediaUrl: url,
                  onRemove: () => onRemovePhoto(url),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (date.photoUrls.isEmpty)
                PolaroidPhoto(caption: date.title, width: 220)
              else
                _AddPhotoTile(onTap: onAddPhoto),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(dateLabel, style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.sm),
        if (date.tagNote.isNotEmpty) ...[
          StickyNoteTag(text: date.tagNote),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (date.photoUrls.isEmpty)
          TextButton.icon(
            onPressed: onAddPhoto,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('Add a photo'),
          ),
        TextButton.icon(
          onPressed: onDeleteDate,
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
          label: const Text('Delete date', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}

class _DeletablePolaroid extends StatelessWidget {
  const _DeletablePolaroid({
    required this.caption,
    required this.mediaUrl,
    required this.onRemove,
  });

  final String caption;
  final String mediaUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolaroidPhoto(caption: caption, mediaUrl: mediaUrl, width: 220),
        Positioned(
          top: 4,
          right: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
              color: Colors.white,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderPink, width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted, size: 32),
        ),
      ),
    );
  }
}
