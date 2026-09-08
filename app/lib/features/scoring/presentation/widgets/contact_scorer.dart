import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'contact_field.dart';
import 'one_card_diamond.dart';

class ContactScorer extends StatefulWidget {
  const ContactScorer({
    super.key,
    required this.state,
    required this.onCommit,
    required this.onDraftChanged,
    required this.onPendingChanged,
    required this.onWave,
    this.captureEnabled = true,
  });
  final FieldModeState state;
  final bool captureEnabled;
  final Future<void> Function(LoggedPlay) onCommit;
  final Future<void> Function(String?) onDraftChanged;
  final ValueChanged<bool> onPendingChanged;
  final Future<void> Function(String) onWave;
  @override
  State<ContactScorer> createState() => _ContactScorerState();
}

class _ContactScorerState extends State<ContactScorer> {
  ContactLocation? _location;
  PaResult? _result;
  OutKind? _kind;
  int? _rbi;
  String _phase = 'location';
  String? _quality, _error, _side;
  bool _saving = false;
  Future<void> _writes = Future.value();
  int get _sequence => [
    0,
    ...widget.state.events.map((e) => e.sequence),
    ...widget.state.replay.pas.map((p) => p.sequence),
  ].reduce((a, b) => a > b ? a : b);
  @override
  void initState() {
    super.initState();
    final s = widget.state.game.scoringDraft;
    if (s != null) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        if (m['version'] == 2 &&
            m['batterId'] == widget.state.batter?.id &&
            m['sequence'] == _sequence) {
          _location = ContactLocation.parse(m['location'] as String?);
          _phase = m['phase'] as String;
          _result = m['result'] == null ? null : PaResult.fromWire(m['result']);
          _kind = OutKind.fromWire(m['kind']);
          _rbi = m['rbi'] as int?;
          _quality = m['quality'] as String?;
          _side = m['side'] as String?;
          if (!['location', 'result', 'how', 'rbi', 'ready'].contains(_phase)) {
            _phase = 'location';
          }
          if (_phase == 'ready') _error = 'Unfinished save. Retry or cancel.';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onPendingChanged(true);
          });
        }
      } catch (_) {
        _error = 'Could not read the unfinished play. Cancel to start again.';
      }
    }
  }

  Future<void> _persist({bool clear = false}) {
    final source = clear
        ? null
        : jsonEncode({
            'version': 2,
            'batterId': widget.state.batter?.id,
            'sequence': _sequence,
            'location': _location?.encode(),
            'phase': _phase,
            'result': _result?.wire,
            'kind': _kind?.wire,
            'rbi': _rbi,
            'quality': _quality,
            'side': _side,
          });
    _writes = _writes
        .catchError((Object _) {})
        .then((_) => widget.onDraftChanged(source));
    return _writes;
  }

  void _changed() {
    if (_phase == 'location') setState(() => _phase = 'result');
    widget.onPendingChanged(true);
    unawaited(
      _persist().catchError((Object e) {
        if (mounted) {
          setState(
            () => _error =
                'Draft could not be saved. Keep this screen open and retry.',
          );
        }
      }),
    );
  }

  void _pick(ContactLocation? p) {
    if (_saving) return;
    setState(() {
      _location = p;
      _phase = 'result';
      _error = null;
    });
    unawaited(HapticFeedback.selectionClick());
    _changed();
  }

  void _out() {
    if (_saving) return;
    setState(() {
      _location = null;
      _result = PaResult.out;
      _phase = 'how';
    });
    _changed();
  }

  void _choose(PaResult result) {
    if (_saving) return;
    setState(() {
      _result = result;
      _kind = null;
      if (result == PaResult.walk || result == PaResult.strikeout) {
        _location = null;
      }
    });
    if (result == PaResult.out) {
      setState(() => _phase = 'how');
      _changed();
    } else {
      _finishQuestions();
    }
  }

  void _finishQuestions() {
    if (widget.state.personal) {
      setState(() => _phase = 'rbi');
      _changed();
    } else {
      unawaited(_file());
    }
  }

  Future<void> _file() async {
    if (_saving || _result == null) return;
    setState(() {
      _saving = true;
      _phase = 'ready';
      _error = null;
    });
    widget.onPendingChanged(true);
    try {
      await _persist();
      final side = _side ?? widget.state.batter?.bats;
      final contact =
          (_result == PaResult.walk || _result == PaResult.strikeout)
          ? null
          : (_location ?? const ContactLocation()).withDetails(
              bats: ['left', 'right'].contains(side) ? side : null,
            );
      await widget.onCommit(
        LoggedPlay(
          result: _result!,
          outKind: _kind,
          rbi: _rbi,
          hitLocation: contact?.encode(),
          qualityOfContact: _quality,
        ),
      );
      if (mounted) {
        setState(() {
          _saving = false;
          _location = null;
          _result = null;
          _kind = null;
          _rbi = null;
          _quality = null;
          _side = null;
          _phase = 'location';
        });
        widget.onPendingChanged(false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Play not saved. Retry or cancel.';
        });
      }
    }
  }

  Future<void> _cancel() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _persist(clear: true);
      if (mounted) {
        setState(() {
          _saving = false;
          _location = null;
          _result = null;
          _kind = null;
          _rbi = null;
          _quality = null;
          _side = null;
          _phase = 'location';
          _error = null;
        });
        widget.onPendingChanged(false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not clear the draft. Try again.';
        });
      }
    }
  }

  Widget _button(String label, VoidCallback action, {String? key}) =>
      OutlinedButton(
        key: key == null ? null : Key(key),
        onPressed: _saving ? null : action,
        child: Text(label),
      );
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final field = context.colors.field;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'BALL LOCATION',
            style: context.text.labelSmall?.copyWith(
              color: field.accent,
              letterSpacing: 2,
            ),
          ),
          if (!state.personal)
            Wrap(
              spacing: 6,
              children: [
                for (var base = 1; base <= 3; base++)
                  if (state.replay.bases.at(base) != null)
                    OutlinedButton(
                      onPressed: _saving || _phase != 'location'
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              widget.onPendingChanged(true);
                              try {
                                await widget.onWave(
                                  state.replay.bases.at(base)!,
                                );
                              } catch (_) {
                                if (mounted) {
                                  setState(
                                    () =>
                                        _error = 'Runner not saved. Try again.',
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _saving = false);
                                  widget.onPendingChanged(false);
                                }
                              }
                            },
                      child: Text(
                        '$base B · ${state.playerById(state.replay.bases.at(base))?.firstName ?? 'Runner'}',
                      ),
                    ),
              ],
            ),
          ContactField(
            fieldMode: true,
            location: _location,
            onLocation:
                state.hasLineup &&
                    widget.captureEnabled &&
                    !_saving &&
                    _phase != 'ready'
                ? _pick
                : null,
            onOut:
                state.hasLineup &&
                    widget.captureEnabled &&
                    !_saving &&
                    _phase != 'ready'
                ? _out
                : null,
          ),
          Text(
            _location?.label ??
                'Location optional · drag the ball or tap the field',
            style: context.text.bodySmall?.copyWith(color: field.on),
          ),
          if (_error != null)
            Text(
              _error!,
              style: context.text.bodySmall?.copyWith(color: field.on),
            ),
          if (state.hasLineup) ...[
            if (_phase == 'ready' && !_saving)
              _button('Retry', () => unawaited(_file()), key: 'contact-retry'),
            if (_phase == 'location' || _phase == 'result') ...[
              if (_phase == 'result')
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final r in [
                      PaResult.single,
                      PaResult.double,
                      PaResult.triple,
                      PaResult.homer,
                      PaResult.out,
                      PaResult.reachOnError,
                      PaResult.fieldersChoice,
                    ])
                      _button(
                        r.label,
                        () => _choose(r),
                        key: 'contact-${r.wire}',
                      ),
                  ],
                ),
              Wrap(
                spacing: 6,
                children: [
                  _button('BB', () => _choose(PaResult.walk)),
                  _button('K', () => _choose(PaResult.strikeout)),
                  _button('Skip location', () => _pick(null)),
                ],
              ),
              if (widget.captureEnabled)
                ExpansionTile(
                  title: const Text('Area / optional detail'),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    Wrap(
                      spacing: 4,
                      children: [
                        for (final region in ContactLocation.regions)
                          _button(
                            region,
                            () => _pick(ContactLocation(region: region)),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 4,
                      children: [
                        for (final flight in ContactLocation.flights)
                          ChoiceChip(
                            label: Text(flight),
                            selected: _location?.flight == flight,
                            onSelected: _saving
                                ? null
                                : (_) {
                                    setState(
                                      () => _location = ContactLocation(
                                        x: _location?.x,
                                        y: _location?.y,
                                        region: _location?.region,
                                        flight: _location?.flight == flight
                                            ? null
                                            : flight,
                                      ),
                                    );
                                    _changed();
                                  },
                          ),
                      ],
                    ),
                    if (state.personal || state.settings.modules.contact)
                      Wrap(
                        spacing: 4,
                        children: [
                          for (final q in ['weak', 'medium', 'hard'])
                            ChoiceChip(
                              label: Text(q),
                              selected: _quality == q,
                              onSelected: _saving
                                  ? null
                                  : (_) {
                                      setState(
                                        () =>
                                            _quality = _quality == q ? null : q,
                                      );
                                      _changed();
                                    },
                            ),
                        ],
                      ),
                    Wrap(
                      spacing: 4,
                      children: [
                        const Text('Batting side'),
                        for (final side in ['left', 'right'])
                          ChoiceChip(
                            label: Text(side),
                            selected: (_side ?? state.batter?.bats) == side,
                            onSelected: _saving
                                ? null
                                : (_) {
                                    setState(() => _side = side);
                                    _changed();
                                  },
                          ),
                      ],
                    ),
                  ],
                ),
            ],
            if (_phase == 'how')
              Wrap(
                spacing: 6,
                children: [
                  for (final k in OutKind.values)
                    _button(k.label, () {
                      setState(() {
                        _kind = k;
                        _location = (_location ?? const ContactLocation())
                            .withDetails(flight: k.wire);
                      });
                      _finishQuestions();
                    }),
                  _button('K', () => _choose(PaResult.strikeout)),
                ],
              ),
            if (_phase == 'rbi')
              Wrap(
                spacing: 6,
                children: [
                  const Text('RBI'),
                  for (var n = _result == PaResult.homer ? 1 : 0; n <= 4; n++)
                    _button('$n', () {
                      _rbi = n;
                      unawaited(_file());
                    }, key: 'contact-rbi-$n'),
                ],
              ),
            if (_phase != 'location' || _location != null || _error != null)
              _button(
                'Cancel',
                () => unawaited(_cancel()),
                key: 'contact-cancel',
              ),
          ],
        ],
      ),
    );
  }
}

Future<ContactLocation?> editContactLocation(
  BuildContext context,
  ContactLocation? initial,
) => showModalBottomSheet<ContactLocation>(
  context: context,
  isScrollControlled: true,
  builder: (context) {
    ContactLocation? value = initial;
    return StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                Text('Ball location', style: context.text.headlineSmall),
                ContactField(
                  location: value,
                  onLocation: (p) => setState(
                    () => value = p.withDetails(
                      flight: value?.flight,
                      bats: value?.bats,
                    ),
                  ),
                ),
                Text(value?.label ?? 'Location unknown'),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final r in ContactLocation.regions)
                      ActionChip(
                        label: Text(r),
                        onPressed: () => setState(
                          () => value = ContactLocation(
                            region: r,
                            flight: value?.flight,
                            bats: value?.bats,
                          ),
                        ),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    for (final f in ContactLocation.flights)
                      ChoiceChip(
                        label: Text(f),
                        selected: value?.flight == f,
                        onSelected: (_) => setState(
                          () => value = ContactLocation(
                            x: value?.x,
                            y: value?.y,
                            region: value?.region,
                            flight: value?.flight == f ? null : f,
                            bats: value?.bats,
                          ),
                        ),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(
                    () => value = ContactLocation(
                      flight: value?.flight,
                      bats: value?.bats,
                    ),
                  ),
                  child: const Text('Clear location'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, value ?? const ContactLocation()),
                  child: const Text('Save detail'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
