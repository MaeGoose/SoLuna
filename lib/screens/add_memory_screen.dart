import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/memories_repository.dart';
import '../models/memory_folder.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Form for adding a new memory, with a photo, and an option to file it
/// into an existing folder or create a new one on the spot. Saving
/// uploads the photo to Supabase Storage and writes the memories/
/// memory_folders rows via MemoriesRepository — there's no local-only
/// fallback anymore, so this needs a network connection to save.
class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _newFolderController = TextEditingController();
  final _picker = ImagePicker();
  DateTime? _date;
  String? _selectedFolderId;
  Uint8List? _photoBytes;
  bool _isSaving = false;
  bool _isLoadingFolders = true;
  List<MemoryFolder> _folders = [];

  static const _newFolderSentinel = '__new__';
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final folders = await MemoriesRepository.fetchFolders();
      if (!mounted) return;
      setState(() {
        _folders = folders;
        _isLoadingFolders = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFolders = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _newFolderController.dispose();
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
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a photo first.')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and a date first.')),
      );
      return;
    }
    if (_selectedFolderId == _newFolderSentinel && _newFolderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name the new folder first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final coupleId = await MemoriesRepository.getOrCreateCoupleId();

      String? folderId = _selectedFolderId;
      if (folderId == _newFolderSentinel) {
        final newFolder = await MemoriesRepository.createFolder(
          coupleId: coupleId,
          title: _newFolderController.text.trim(),
        );
        folderId = newFolder.id;
      }

      await MemoriesRepository.createMemory(
        coupleId: coupleId,
        title: _titleController.text.trim(),
        date: _date!,
        folderId: folderId,
        photoBytes: _photoBytes!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t save that memory. Try again.')),
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
              Text('Add a Memory', style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 200,
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
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text('Tap to add a photo', style: textTheme.labelSmall),
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
              Text('Folder', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFolderId,
                hint: Text(_isLoadingFolders ? 'Loading folders...' : 'No folder'),
                items: [
                  for (final folder in _folders)
                    DropdownMenuItem(value: folder.id, child: Text(folder.title)),
                  const DropdownMenuItem(
                    value: _newFolderSentinel,
                    child: Text('+ New folder'),
                  ),
                ],
                onChanged:
                    _isLoadingFolders ? null : (value) => setState(() => _selectedFolderId = value),
              ),
              if (_selectedFolderId == _newFolderSentinel) ...[
                const SizedBox(height: AppSpacing.md),
                LabeledTextField(
                  label: 'New folder name',
                  controller: _newFolderController,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _isSaving ? 'Saving...' : 'Save Memory',
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
