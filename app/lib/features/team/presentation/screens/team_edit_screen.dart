import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';

class TeamEditScreen extends ConsumerStatefulWidget {
  const TeamEditScreen({super.key});
  @override
  ConsumerState<TeamEditScreen> createState() => _TeamEditScreenState();
}

class _TeamEditScreenState extends ConsumerState<TeamEditScreen> {
  final _name = TextEditingController();
  String _type = 'mens';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'New team',
      body: Padding(
        padding: EdgeInsets.all(context.themeSpacing.md),
        child: Column(
          children: [
            AppTextField(label: 'Team name', controller: _name),
            SizedBox(height: context.themeSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'mens', child: Text("Men's")),
                DropdownMenuItem(value: 'womens', child: Text("Women's")),
                DropdownMenuItem(value: 'coed', child: Text('Coed')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'mens'),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            SizedBox(height: context.themeSpacing.lg),
            AppButton(
              label: 'Save',
              onPressed: () async {
                final team = await ref.read(trackerRepositoryProvider).createTeam(
                      name: _name.text.trim(),
                      type: _type,
                    );
                await ref.read(meRepositoryProvider).attachMeToNewTeam(team.id);
                ref.read(currentTeamIdProvider.notifier).state = team.id;
                if (context.mounted) context.go('/team');
              },
            ),
          ],
        ),
      ),
    );
  }
}
