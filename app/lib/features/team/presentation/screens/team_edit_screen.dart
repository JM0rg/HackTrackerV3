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
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'New team',
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.themeSpacing.md),
        child: Column(
          children: [
            AppTextField(
              label: 'Team name',
              controller: _name,
              onChanged: (_) => setState(() {}),
            ),
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
            if (_error != null) Text(_error!),
            AppButton(
              label: 'Save',
              onPressed: _saving || _name.text.trim().isEmpty ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || _name.text.trim().isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final team = await ref.read(databaseProvider).transaction(() async {
        final created = await ref
            .read(trackerRepositoryProvider)
            .createTeam(name: _name.text.trim(), type: _type);
        await ref.read(meRepositoryProvider).attachMeToNewTeam(created.id);
        return created;
      });
      if (!mounted) return;
      ref.read(currentTeamIdProvider.notifier).state = team.id;
      context.go('/team');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not create the team. Try again.';
        });
      }
    }
  }
}
