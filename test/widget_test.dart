// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:habitnord/main.dart';

void main() {
  testWidgets('HabitNord home renders and add habit dialog opens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HabitNordRoot());
    expect(find.text('HabitNord'), findsOneWidget);

    // Open add habit dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add Habit'), findsOneWidget);
  });
  testWidgets('App renders HabitNord home', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitNordRoot());

    // Verify app bar title exists
    expect(find.text('HabitNord'), findsOneWidget);

    // Add habit dialog opens
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add Habit'), findsOneWidget);
  });
}
