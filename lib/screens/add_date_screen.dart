import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/couple_date.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';

/// Form for adding a new saved date. Appends straight to
/// sampleCoupleDates — no backend yet.
class AddDateScreen extends StatefulWidget {
  const AddDateScreen({super.key});

  @override
  State<AddDateScreen> createState() => _AddDateScreenState();
}

class _AddDateScreenState extends State<AddDateScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _tagController = TextEditingController();
  DateTime? _date;

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

  void _save() {
    if (_titleController.text.trim().isEmpty || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and a date first.')),
      );
      return;
    }

    sampleCoupleDates.add(
      CoupleDate(
        id: 'd${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        date: _date!,
        tagNote: _tagController.text.trim().isEmpty
            ? 'A new date to remember'
            : _tagController.text.trim(),
      ),
    );

    Navigator.pop(context, true);
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
              AppButton(label: 'Save Date', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
