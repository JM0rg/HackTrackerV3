import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/core/widgets/text_entry_sheet.dart';

void main() {
  testWidgets(
    'entry sheet validates, rejects duplicate saves, and retries without losing text',
    (t) async {
      var calls = 0;
      final firstSave = Completer<void>();
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => TextEntrySheet(
                    fields: const [TextEntryField('Name', required: true)],
                    onSave: (values) async {
                      expect(values.single, 'Casey');
                      calls++;
                      if (calls == 1) await firstSave.future;
                    },
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      expect(
        t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await t.enterText(find.byType(TextField), '  Casey  ');
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pump();
      await t.tap(find.text('Save'));
      await t.pump();
      expect(calls, 1);
      firstSave.completeError(StateError('test failure'));
      await t.pumpAndSettle();
      expect(find.text('Could not save. Try again.'), findsOneWidget);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        '  Casey  ',
      );
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(calls, 2);
      expect(find.byType(TextEntrySheet), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
}
