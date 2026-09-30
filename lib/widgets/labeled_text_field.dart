import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// An uppercase label sitting above a pink-bordered text field — used on
/// Create Account and Settings for every form field.
///
/// [obscureText] toggles a password dot-mask with an eye icon the person
/// can tap to reveal it; that reveal state is purely local UI state, not
/// app data, so it is the one thing this widget is allowed to manage
/// itself. Everything the app actually needs (what was typed) still lives
/// in the [controller] the caller owns.
///
/// [errorText] renders inline red validation text below the field, plus a
/// red border — pass null (the default) to show neither.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final String? errorText;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            errorText: widget.errorText,
            errorMaxLines: 2,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
            // The app-wide theme already sets a pink border; only
            // override it here when there's actually an error to show.
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                  )
                : null,
            focusedBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.75),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
