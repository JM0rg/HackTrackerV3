import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/play_resolution.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';

Future<void> showRunnerResolution(
  BuildContext context, {
  required FieldModeState state,
  required String paId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _RunnerResolution(state: state, paId: paId),
);

class _RunnerResolution extends ConsumerStatefulWidget {
  const _RunnerResolution({required this.state, required this.paId});
  final FieldModeState state;
  final String paId;
  @override
  ConsumerState<_RunnerResolution> createState() => _RunnerResolutionState();
}

class _RunnerResolutionState extends ConsumerState<_RunnerResolution> {
  List<RunnerDecision>? _runners;
  String? _error;
  bool _negates = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final value = await ref
          .read(scoringRepositoryProvider)
          .resolutionFor(widget.state.game.id, widget.paId);
      if (!mounted) return;
      setState(() {
        _runners = value.resolution.runners;
        _negates = value.resolution.thirdOutNegatesRuns;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _update(int index, {int? destination, bool? rbi}) {
    setState(() {
      final old = _runners![index];
      _runners![index] = RunnerDecision(
        playerId: old.playerId,
        destination: destination ?? old.destination,
        rbi: rbi ?? old.rbi,
      );
      _error = null;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(scoringRepositoryProvider)
          .setResolution(
            game: widget.state.game,
            paId: widget.paId,
            resolution: PlayResolution(
              runners: _runners!,
              thirdOutNegatesRuns: _negates,
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '$error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final runners = _runners;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where did everyone finish?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hit credit stays the same. Adjust advances, outs, and RBI here.',
            ),
            const SizedBox(height: 16),
            if (runners != null)
              for (var i = 0; i < runners.length; i++) ...[
                Text(
                  widget.state.playerById(runners[i].playerId)?.firstName ??
                      'Runner',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (var d = 0; d <= 4; d++)
                      ChoiceChip(
                        label: Text(
                          const ['Out', '1B', '2B', '3B', 'Scored'][d],
                        ),
                        selected: runners[i].destination == d,
                        onSelected: _saving
                            ? null
                            : (_) => _update(i, destination: d),
                      ),
                  ],
                ),
                if (runners[i].destination == 4)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Credit an RBI'),
                    subtitle: const Text(
                      'Turn off for a run caused by an error.',
                    ),
                    value: runners[i].rbi,
                    onChanged: _saving ? null : (v) => _update(i, rbi: v),
                  ),
                const SizedBox(height: 12),
              ],
            if (runners != null &&
                runners.any((r) => r.destination == 0) &&
                runners.any((r) => r.destination == 4))
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Runs crossed before a tag for the third out',
                ),
                subtitle: const Text(
                  'Only for a non-force out. A force third out or batter retired before first cancels all runs.',
                ),
                value: !_negates,
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _negates = !v),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: runners == null || _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save play'),
            ),
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
