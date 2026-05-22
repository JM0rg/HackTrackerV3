import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// The canonical labeled text input. Wraps Material's [TextField] with token
/// styling so forms stay visually consistent.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.md),
      borderSide: BorderSide(color: color),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.label),
        SizedBox(height: spacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          autofocus: autofocus,
          onChanged: onChanged,
          style: context.text.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.text.body.copyWith(color: colors.secondaryText),
            errorText: errorText,
            isDense: true,
            filled: true,
            fillColor: colors.surfaceAlt,
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.md,
            ),
            enabledBorder: border(colors.border),
            focusedBorder: border(colors.primary),
            errorBorder: border(colors.danger),
            focusedErrorBorder: border(colors.danger),
          ),
        ),
      ],
    );
  }
}
