import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/couple_dates_repository.dart';
import '../data/memories_repository.dart';
import '../models/date_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Form for adding a new saved date, with any number of photos (zero is
/// fine too). Saves to Supabase via CoupleDatesRepository — each photo
/// uploads the same way AddMemoryScreen's does.
class AddDateScreen extends StatefulWidget {
  const AddDateScreen({super.key});

  @override
  State<AddDateScreen> createState() => _AddDateScreenState();
}

class _AddDateScreenState extends State<AddDateScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _tagController = TextEditingController();
  final _newCategoryController = TextEditingController();
  final _picker = ImagePicker();
  DateTime? _date;
  final List<Uint8List> _photos = [];
  bool _isSaving = false;
  bool _isLoadingCategories = true;
  String? _selectedCategoryId;
  List<DateCategory> _categories = [];

  static const _newCategorySentinel = '__new__';
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CoupleDatesRepository.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _tagController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final allBytes = await Future.wait(picked.map((f) => f.readAsBytes()));
    setState(() => _photos.addAll(allBytes));
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = '${_months[picked.month - 1]} ${picked.day}, ${picked.year}';
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and a date first.')),
      );
      return;
    }
    if (_selectedCategoryId == _newCategorySentinel && _newCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name the new category first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? categoryId = _selectedCategoryId;
      if (categoryId == _newCategorySentinel) {
        final coupleId = await MemoriesRepository.getOrCreateCoupleId();
        final newCategory = await CoupleDatesRepository.createCategory(
          coupleId: coupleId,
          title: _newCategoryController.text.trim(),
        );
        categoryId = newCategory.id;
      }

      await CoupleDatesRepository.createDate(
        title: _titleController.text.trim(),
        date: _date!,
        tagNote: _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
        categoryId: categoryId,
        photos: _photos,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t save that date. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              Text('Add a Date', style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.lg),
              Text('Photos (optional)', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 0; i < _photos.length; i++) ...[
                      _PhotoThumb(bytes: _photos[i], onRemove: () => _removePhoto(i)),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    _AddPhotoTile(onTap: _addPhotos),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledTextField(label: 'Title', controller: _titleController),
              const SizedBox(height: AppSpacing.md),
              LabeledTextField(
                label: 'Date',
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledTextField(label: 'Note (optional)', controller: _tagController),
              const SizedBox(height: AppSpacing.md),
              Text('Category (optional)', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: Text(_isLoadingCategories ? 'Loading categories...' : 'No category'),
                items: [
                  for (final category in _categories)
                    DropdownMenuItem(value: category.id, child: Text(category.title)),
                  const DropdownMenuItem(
                    value: _newCategorySentinel,
                    child: Text('+ New category'),
                  ),
                ],
                onChanged: _isLoadingCategories
                    ? null
                    : (value) => setState(() => _selectedCategoryId = value),
              ),
              if (_selectedCategoryId == _newCategorySentinel) ...[
                const SizedBox(height: AppSpacing.md),
                LabeledTextField(
                  label: 'New category name',
                  controller: _newCategoryController,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _isSaving ? 'Saving...' : 'Save Date',
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(bytes, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 14),
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
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
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderPink, width: 1.5),
        ),
        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textMuted),
      ),
    );
  }
}
