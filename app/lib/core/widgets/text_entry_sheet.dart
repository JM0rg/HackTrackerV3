import 'package:flutter/material.dart';
import '../theme/theme_context_extensions.dart';
import 'app_widgets.dart';

class TextEntryField {
  const TextEntryField(this.label, {this.initial = '', this.required = false});
  final String label, initial;
  final bool required;
}

/// The sheet owns controllers until its exit animation finishes, and remains
/// scrollable above the native keyboard. A save can only be submitted once.
class TextEntrySheet extends StatefulWidget {
  const TextEntrySheet({
    super.key,
    required this.fields,
    required this.onSave,
    this.header,
  });
  final List<TextEntryField> fields;
  final Future<void> Function(List<String>) onSave;
  final Widget? header;
  @override
  State<TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<TextEntrySheet> {
  late final _controllers = widget.fields
      .map((f) => TextEditingController(text: f.initial))
      .toList();
  bool _saving = false;
  String? _error;
  bool get _valid => widget.fields.indexed.every(
    (f) => !f.$2.required || _controllers[f.$1].text.trim().isNotEmpty,
  );
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_valid) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_controllers.map((c) => c.text.trim()).toList());
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetGrabber(),
        const SizedBox(height: 12),
        if (widget.header != null) widget.header!,
        for (final entry in widget.fields.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppTextField(
              label: entry.$2.label,
              controller: _controllers[entry.$1],
              onChanged: (_) => setState(() {}),
            ),
          ),
        const SizedBox(height: 16),
        if (_error != null) Text(_error!, style: context.text.bodySmall),
        AppButton(label: 'Save', onPressed: !_valid || _saving ? null : _save),
      ],
    ),
  );
}
