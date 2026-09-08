import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

/// Pick a team you have saved, or add one. Returns the chosen team, or null
/// if the sheet was dismissed.
Future<PersonalTeam?> showPersonalTeamPicker(BuildContext context) {
  return showModalBottomSheet<PersonalTeam>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _PickerSheet(),
  );
}

class _PickerSheet extends ConsumerWidget {
  const _PickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.themeSpacing;
    final teams =
        ref.watch(personalTeamsStreamProvider).valueOrNull ??
        const <PersonalTeam>[];

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.sm,
          spacing.md,
          spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Grabber(),
            SizedBox(height: spacing.md),
            Text('Playing with', style: context.text.titleMedium),
            SizedBox(height: spacing.sm),
            if (teams.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.42,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Dismissible(
                      key: Key('team-${team.id}'),
                      direction: DismissDirection.endToStart,
                      background: ColoredBox(
                        color: context.colors.danger,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.md),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      confirmDismiss: (_) => confirmAction(
                        context,
                        title: 'Forget ${team.name}?',
                        body: 'Games already tagged keep the name.',
                      ),
                      onDismissed: (_) => ref
                          .read(meRepositoryProvider)
                          .deletePersonalTeam(team.id),
                      child: ListTile(
                        key: Key('pick-${team.id}'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.groups_outlined),
                        title: Text(team.name),
                        onTap: () => Navigator.pop(context, team),
                      ),
                    );
                  },
                ),
              ),
            const Divider(),
            ListTile(
              key: const Key('add-team'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add, color: context.colors.accent),
              title: Text(
                'Add new team',
                style: context.text.titleSmall?.copyWith(
                  color: context.colors.accent,
                ),
              ),
              onTap: () async {
                final created = await _showAddTeam(context);
                if (created != null && context.mounted) {
                  Navigator.pop(context, created);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<PersonalTeam?> _showAddTeam(BuildContext context) {
  return showModalBottomSheet<PersonalTeam>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AddTeamSheet(),
  );
}

/// Owns its own text controller, so nothing is disposed while the sheet is
/// still animating away.
class _AddTeamSheet extends ConsumerStatefulWidget {
  const _AddTeamSheet();

  @override
  ConsumerState<_AddTeamSheet> createState() => _AddTeamSheetState();
}

class _AddTeamSheetState extends ConsumerState<_AddTeamSheet> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final created = await ref
        .read(meRepositoryProvider)
        .createPersonalTeam(_name.text);
    if (created != null && mounted) Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        spacing.sm,
        spacing.md,
        MediaQuery.of(context).viewInsets.bottom + spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Grabber(),
          SizedBox(height: spacing.md),
          Text('New team', style: context.text.titleMedium),
          SizedBox(height: spacing.md),
          AppTextField(
            key: const Key('new-team-name'),
            label: 'Team name',
            controller: _name,
            placeholder: 'Tuesday pickup',
          ),
          SizedBox(height: spacing.md),
          AppButton(label: 'Save team', onPressed: _save),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
