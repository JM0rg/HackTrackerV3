import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../teams/data/teams_repository.dart';
import '../../data/games_repository.dart';
import '../../domain/game.dart';
import '../controllers/game_edit_controller.dart';

/// Create (null [game]) or edit a game. New games are scoped to the currently
/// selected team; when editing, the team is fixed (a game belongs to one team
/// for life).
class GameEditScreen extends ConsumerStatefulWidget {
  const GameEditScreen({this.game, super.key});

  final Game? game;

  @override
  ConsumerState<GameEditScreen> createState() => _GameEditScreenState();
}

class _GameEditScreenState extends ConsumerState<GameEditScreen> {
  late final _opponent = TextEditingController(
    text: widget.game?.opponentName ?? '',
  );
  late final _park = TextEditingController(text: widget.game?.parkName ?? '');
  late final _city = TextEditingController(
    text: widget.game?.cityOrAddress ?? '',
  );
  late final _notes = TextEditingController(text: widget.game?.notes ?? '');
  late final _ourScore = TextEditingController(
    text: widget.game?.ourScore?.toString() ?? '',
  );
  late final _oppScore = TextEditingController(
    text: widget.game?.oppScore?.toString() ?? '',
  );

  late HomeAway _homeAway = widget.game?.homeAway ?? HomeAway.home;
  late GameStatus _status = widget.game?.status ?? GameStatus.scheduled;
  late DateTime? _startTime = widget.game?.startTime;

  @override
  void dispose() {
    _opponent.dispose();
    _park.dispose();
    _city.dispose();
    _notes.dispose();
    _ourScore.dispose();
    _oppScore.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final base = _startTime?.toLocal() ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (!mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? base.hour,
      time?.minute ?? base.minute,
    );
    setState(() => _startTime = picked.toUtc());
  }

  Future<void> _save() async {
    final teamId = widget.game?.teamId ?? ref.read(currentTeamIdProvider);
    if (teamId == null) return; // gate ensures a team exists when creating.
    final ok = await ref
        .read(gameEditControllerProvider.notifier)
        .save(
          id: widget.game?.id,
          teamId: teamId,
          homeAway: _homeAway,
          status: _status,
          opponentName: _opponent.text,
          parkName: _park.text,
          cityOrAddress: _city.text,
          startTime: _startTime,
          ourScore: int.tryParse(_ourScore.text.trim()),
          oppScore: int.tryParse(_oppScore.text.trim()),
          notes: _notes.text,
        );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete game?',
      message: 'This removes the game from your schedule.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(gamesRepositoryProvider).softDelete(widget.game!.id);
    if (mounted) Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime utc) {
    final local = utc.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameEditControllerProvider);
    final spacing = context.themeSpacing;
    final isEditing = widget.game != null;

    return AppScaffold(
      title: isEditing ? 'Edit game' : 'New game',
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Opponent',
            controller: _opponent,
            hint: 'e.g. Night Hawks',
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'Park',
            controller: _park,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: spacing.md),
          AppTextField(
            label: 'City / address',
            controller: _city,
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: spacing.lg),
          Text('Date & time', style: context.text.label),
          SizedBox(height: spacing.sm),
          AppButton(
            label: _startTime == null
                ? 'Pick date & time'
                : _formatDateTime(_startTime!),
            variant: AppButtonVariant.secondary,
            icon: Icons.event_outlined,
            onPressed: _pickDateTime,
          ),
          SizedBox(height: spacing.lg),
          _ChipGroup<HomeAway>(
            label: 'Home / away',
            values: HomeAway.values,
            selected: _homeAway,
            labelOf: (h) => h.label,
            onSelected: (h) => setState(() => _homeAway = h ?? HomeAway.home),
          ),
          SizedBox(height: spacing.md),
          _ChipGroup<GameStatus>(
            label: 'Status',
            values: GameStatus.values,
            selected: _status,
            labelOf: (s) => s.label,
            onSelected: (s) =>
                setState(() => _status = s ?? GameStatus.scheduled),
          ),
          SizedBox(height: spacing.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Our score',
                  controller: _ourScore,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Opp score',
                  controller: _oppScore,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          AppTextField(label: 'Notes', controller: _notes, maxLines: 3),
          SizedBox(height: spacing.xl),
          AppButton(
            label: isEditing ? 'Save changes' : 'Add game',
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
              label: 'Delete game',
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
          runSpacing: spacing.xs,
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
