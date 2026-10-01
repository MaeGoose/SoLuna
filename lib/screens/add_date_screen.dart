import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/couple_dates_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Form for adding a new saved date. Saves to Supabase via
/// CoupleDatesRepository — the photo (optional) uploads the same way
/// AddMemoryScreen's does.
class AddDateScreen extends StatefulWidget {
  const AddDateScreen({super.key});

  @override
  State<AddDateScreen> createState() => _AddDateScreenState();
}

class _AddDateScreenState extends State<AddDateScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _tagController = TextEditingController();
  final _picker = ImagePicker();
  DateTime? _date;
  Uint8List? _photoBytes;
  bool _isSaving = false;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes = bytes);
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

    setState(() => _isSaving = true);
    try {
      await CoupleDatesRepository.createDate(
        title: _titleController.text.trim(),
        date: _date!,
        tagNote: _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
        photoBytes: _photoBytes,
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
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderPink, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _photoBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 36,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Tap to add a photo (optional)', style: textTheme.labelSmall),
                          ],
                        )
                      : Image.memory(_photoBytes!, fit: BoxFit.cover),
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
