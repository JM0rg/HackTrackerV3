import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/field_position.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../data/players_repository.dart';
import '../../domain/player.dart';
import '../controllers/player_edit_controller.dart';

/// Create (null [player]) or edit a roster player.
class PlayerEditScreen extends ConsumerStatefulWidget {
  const PlayerEditScreen({required this.teamId, this.player, super.key});

  final String teamId;
  final Player? player;

  @override
  ConsumerState<PlayerEditScreen> createState() => _PlayerEditScreenState();
}

class _PlayerEditScreenState extends ConsumerState<PlayerEditScreen> {
  late final _name = TextEditingController(text: widget.player?.name ?? '');
  late final _number = TextEditingController(
    text: widget.player?.jerseyNumber ?? '',
  );
  late final _phone = TextEditingController(text: widget.player?.phone ?? '');
  late final _email = TextEditingController(text: widget.player?.email ?? '');

  late PlayerStatus _status = widget.player?.status ?? PlayerStatus.fullTime;
  late BattingSide? _bats = widget.player?.bats;
  late Handedness? _throws = widget.player?.throws;
  late String? _gender = widget.player?.gender;
  late final Set<String> _positions = {...?widget.player?.defaultPositions};

  static const _genders = {
    'male': 'Male',
    'female': 'Female',
    'nonbinary': 'Non-binary',
  };

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref
        .read(playerEditControllerProvider.notifier)
        .save(
          id: widget.player?.id,
          teamId: widget.teamId,
          name: _name.text,
          status: _status,
          jerseyNumber: _number.text,
          throws: _throws,
          bats: _bats,
          gender: _gender,
          defaultPositions: _positions.toList(),
          phone: _phone.text,
          email: _email.text,
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Remove player?',
      message: 'This removes ${widget.player!.name} from the roster.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(playersRepositoryProvider).softDelete(widget.player!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerEditControllerProvider);
    final spacing = context.themeSpacing;
    final isEditing = widget.player != null;

    return AppScaffold(
      title: isEditing ? 'Edit player' : 'New player',
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Name',
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofocus: !isEditing,
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Jersey number',
            controller: _number,
            hint: 'e.g. 00',
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: spacing.lg),
          _ChipGroup<BattingSide>(
            label: 'Bats',
            values: BattingSide.values,
            selected: _bats,
            labelOf: (b) => b.label,
            onSelected: (b) => setState(() => _bats = b),
          ),
          SizedBox(height: spacing.md),
          _ChipGroup<Handedness>(
            label: 'Throws',
            values: Handedness.values,
            selected: _throws,
            labelOf: (h) => h.label,
            onSelected: (h) => setState(() => _throws = h),
          ),
          SizedBox(height: spacing.md),
          _ChipGroup<PlayerStatus>(
            label: 'Status',
            values: PlayerStatus.values,
            selected: _status,
            labelOf: (s) => s.label,
            onSelected: (s) =>
                setState(() => _status = s ?? PlayerStatus.fullTime),
          ),
          SizedBox(height: spacing.md),
          Text('Gender', style: context.text.label),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            children: [
              for (final entry in _genders.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _gender == entry.key,
                  onSelected: (sel) =>
                      setState(() => _gender = sel ? entry.key : null),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text('Default positions', style: context.text.label),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              for (final pos in FieldPosition.values)
                FilterChip(
                  label: Text(pos.code),
                  selected: _positions.contains(pos.code),
                  onSelected: (sel) => setState(() {
                    sel
                        ? _positions.add(pos.code)
                        : _positions.remove(pos.code);
                  }),
                ),
            ],
          ),
          SizedBox(height: spacing.lg),
          AppTextField(
            label: 'Phone (optional)',
            controller: _phone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Email (optional)',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: isEditing ? 'Save changes' : 'Add player',
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
              label: 'Remove from roster',
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

/// Single-select chip row bound to an enum.
class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.label),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.sm,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(labelOf(value)),
                selected: selected == value,
                onSelected: (sel) => onSelected(sel ? value : null),
              ),
          ],
        ),
      ],
    );
  }
}
