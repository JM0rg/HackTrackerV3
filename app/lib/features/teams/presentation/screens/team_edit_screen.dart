import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/team.dart';
import '../controllers/team_edit_controller.dart';

/// Create (when [team] is null) or edit a team. Presented as a full-screen
/// modal via the root navigator.
class TeamEditScreen extends ConsumerStatefulWidget {
  const TeamEditScreen({this.team, super.key});

  final Team? team;

  @override
  ConsumerState<TeamEditScreen> createState() => _TeamEditScreenState();
}

class _TeamEditScreenState extends ConsumerState<TeamEditScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.team?.name ?? '',
  );
  late TeamType _type = widget.team?.teamType ?? TeamType.coed;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final savedId = await ref
        .read(teamEditControllerProvider.notifier)
        .save(id: widget.team?.id, name: _name.text, teamType: _type);
    if (savedId != null && mounted) Navigator.of(context).pop(savedId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamEditControllerProvider);
    final spacing = context.themeSpacing;
    final isEditing = widget.team != null;

    return AppScaffold(
      title: isEditing ? 'Edit team' : 'New team',
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Team name',
            controller: _name,
            hint: 'Sandlot Sluggers',
            textCapitalization: TextCapitalization.words,
            autofocus: !isEditing,
          ),
          SizedBox(height: spacing.lg),
          Text('Team type', style: context.text.label),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            children: [
              for (final type in TeamType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: isEditing ? 'Save changes' : 'Create team',
            isBusy: state.isSaving,
            onPressed: state.isSaving ? null : _save,
          ),
          if (state.errorMessage != null) ...[
            SizedBox(height: spacing.md),
            Text(
              state.errorMessage!,
              style: context.text.caption.copyWith(
                color: context.colors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
