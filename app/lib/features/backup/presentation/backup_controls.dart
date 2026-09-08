import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/backup/data/local_backup.dart';
import 'package:share_plus/share_plus.dart';

class BackupControls extends ConsumerStatefulWidget {
  const BackupControls({super.key, required this.signedIn});
  final bool signedIn;
  @override
  ConsumerState<BackupControls> createState() => _BackupControlsState();
}

class _BackupControlsState extends ConsumerState<BackupControls> {
  bool _busy = false;
  String? _message;

  Future<void> _perform(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on FormatException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _message =
              'Could not finish. Your current data is still on this phone.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Backup', style: context.text.titleMedium),
      const SizedBox(height: 8),
      Text(
        'Save a portable copy of your games and roster. The file includes personal data and is not encrypted.',
        style: context.text.bodySmall,
      ),
      Wrap(
        spacing: 12,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.ios_share),
            label: const Text('Export backup'),
            onPressed: _busy
                ? null
                : () => _perform(() async {
                    final box = context.findRenderObject() as RenderBox?;
                    final origin = box == null
                        ? null
                        : box.localToGlobal(Offset.zero) & box.size;
                    final data = await LocalBackup(
                      ref.read(databaseProvider),
                    ).export();
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [
                          XFile.fromData(
                            Uint8List.fromList(utf8.encode(data)),
                            mimeType: 'application/json',
                          ),
                        ],
                        fileNameOverrides: [
                          'hacktracker-${DateTime.now().toIso8601String().substring(0, 10)}.json',
                        ],
                        sharePositionOrigin: origin,
                      ),
                    );
                  }),
          ),
          TextButton.icon(
            icon: const Icon(Icons.restore),
            label: const Text('Restore backup'),
            onPressed: _busy || widget.signedIn
                ? null
                : () => _perform(() async {
                    final file = await openFile(
                      acceptedTypeGroups: const [
                        XTypeGroup(
                          label: 'HackTracker backup',
                          extensions: ['json'],
                          mimeTypes: ['application/json'],
                          uniformTypeIdentifiers: ['public.json'],
                        ),
                      ],
                    );
                    if (file == null || !context.mounted) return;
                    if (await file.length() > LocalBackup.maxBytes) {
                      throw const FormatException('Backup exceeds 32 MB.');
                    }
                    final source = await file.readAsString();
                    if (!context.mounted) return;
                    final backup = LocalBackup(ref.read(databaseProvider));
                    final tables = backup.inspect(source);
                    final approved = await confirmAction(
                      context,
                      title: 'Replace local data?',
                      body:
                          'Restore ${tables['games']!.length} games and ${tables['teams']!.length} teams from this file. This replaces everything currently on this phone. Export your current backup first.',
                    );
                    if (!approved || !context.mounted) return;
                    await backup.restore(source);
                    if (context.mounted) context.go('/');
                  }),
          ),
        ],
      ),
      if (widget.signedIn)
        Text(
          'Sign out before restoring a local backup.',
          style: context.text.bodySmall,
        ),
      if (_message != null) Text(_message!, style: context.text.bodySmall),
    ],
  );
}
