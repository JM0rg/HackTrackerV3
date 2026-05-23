import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../teams/domain/team.dart';
import '../../data/groups_repository.dart';
import '../../domain/group.dart';
import '../controllers/group_edit_controller.dart';

/// Create (null [group]) or edit a group.
class GroupEditScreen extends ConsumerStatefulWidget {
  const GroupEditScreen({this.group, super.key});

  final Group? group;

  @override
  ConsumerState<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends ConsumerState<GroupEditScreen> {
  late final _name = TextEditingController(text: widget.group?.name ?? '');
  late final _league = TextEditingController(
    text: widget.group?.leagueName ?? '',
  );
  late final _location = TextEditingController(
    text: widget.group?.location ?? '',
  );

  late GroupType _type = widget.group?.groupType ?? GroupType.season;
  late DateTime? _startDate = widget.group?.startDate;
  late DateTime? _endDate = widget.group?.endDate;
  late String? _teamId = widget.group?.teamId;

  @override
  void dispose() {
    _name.dispose();
    _league.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final current = (isStart ? _startDate : _endDate)?.toLocal();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final utc = DateTime.utc(picked.year, picked.month, picked.day);
      if (isStart) {
        _startDate = utc;
      } else {
        _endDate = utc;
      }
    });
  }

  Future<void> _save() async {
    final ok = await ref
        .read(groupEditControllerProvider.notifier)
        .save(
          id: widget.group?.id,
          teamId: _teamId ?? '',
          name: _name.text,
          groupType: _type,
          leagueName: _league.text,
          location: _location.text,
          startDate: _startDate,
          endDate: _endDate,
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete group?',
      message: 'This removes the group. Games stay on your schedule.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(groupsRepositoryProvider).softDelete(widget.group!.id);
    if (mounted) Navigator.of(context).pop();
  }

  String _formatDate(DateTime utc) {
    final local = utc.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupEditControllerProvider);
    final teams = ref.watch(teamsStreamProvider);
    final spacing = context.themeSpacing;
    final isEditing = widget.group != null;

    return AppScaffold(
      title: isEditing ? 'Edit group' : 'New group',
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          teams.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text(
              '$e',
              style: context.text.caption.copyWith(
                color: context.colors.danger,
              ),
            ),
            data: (list) {
              if (!isEditing && _teamId == null && list.length == 1) {
                _teamId = list.first.id;
              }
              return _TeamPicker(
                teams: list,
                selectedId: _teamId,
                enabled: !isEditing,
                onChanged: (id) => setState(() => _teamId = id),
              );
            },
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Name',
            controller: _name,
            hint: 'e.g. Summer 2026',
            textCapitalization: TextCapitalization.words,
            autofocus: !isEditing,
          ),
          SizedBox(height: spacing.lg),
          Text('Type', style: context.text.label),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            children: [
              for (final type in GroupType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'League (optional)',
            controller: _league,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Location (optional)',
            controller: _location,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: spacing.lg),
          _DateRow(
            label: 'Start date',
            value: _startDate == null ? null : _formatDate(_startDate!),
            onPick: () => _pickDate(isStart: true),
            onClear: _startDate == null
                ? null
                : () => setState(() => _startDate = null),
          ),
          SizedBox(height: spacing.md),
          _DateRow(
            label: 'End date',
            value: _endDate == null ? null : _formatDate(_endDate!),
            onPick: () => _pickDate(isStart: false),
            onClear: _endDate == null
                ? null
                : () => setState(() => _endDate = null),
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: isEditing ? 'Save changes' : 'Create group',
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
          if (isEditing) ...[
            SizedBox(height: spacing.md),
            AppButton(
              label: 'Delete group',
              variant: AppButtonVariant.destructive,
              onPressed: _delete,
            ),
          ],
          SizedBox(height: spacing.xl),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.label),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: value ?? 'Pick date',
                variant: AppButtonVariant.secondary,
                icon: Icons.event_outlined,
                onPressed: onPick,
              ),
            ),
            if (onClear != null)
              IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
          ],
        ),
      ],
    );
  }
}

/// Single-select chip row for picking the group's team. Disabled when editing.
class _TeamPicker extends StatelessWidget {
  const _TeamPicker({
    required this.teams,
    required this.selectedId,
    required this.enabled,
    required this.onChanged,
  });

  final List<Team> teams;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Team', style: context.text.label),
        SizedBox(height: spacing.sm),
        if (teams.isEmpty)
          Text(
            'Create a team first',
            style: context.text.caption.copyWith(
              color: context.colors.secondaryText,
            ),
          )
        else
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              for (final team in teams)
                ChoiceChip(
                  label: Text(team.name),
                  selected: selectedId == team.id,
                  onSelected: enabled ? (_) => onChanged(team.id) : null,
                ),
            ],
          ),
      ],
    );
  }
}
