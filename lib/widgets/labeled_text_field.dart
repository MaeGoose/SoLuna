import 'package:flutter/material.dart';

/// An uppercase label sitting above a pink-bordered text field — used on
/// Create Account and Settings for every form field.
///
/// [obscureText] toggles a password dot-mask with an eye icon the person
/// can tap to reveal it; that reveal state is purely local UI state, not
/// app data, so it is the one thing this widget is allowed to manage
/// itself. Everything the app actually needs (what was typed) still lives
/// in the [controller] the caller owns.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          keyboardType: widget.keyboardType,
          style: textTheme.bodyMedium,
          decoration: InputDecoration(
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
