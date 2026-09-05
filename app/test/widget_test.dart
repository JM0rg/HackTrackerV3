import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';

void main() {
  testWidgets('empty state shows title and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: EmptyState(
            title: 'Create a team to start scoring.',
            actionLabel: 'New team',
            onAction: () {},
          ),
        ),
      ),
    );
    expect(find.text('Create a team to start scoring.'), findsOneWidget);
    expect(find.text('New team'), findsOneWidget);
  });
}
