// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitnord/hooks/translations.dart';

import 'package:habitnord/main.dart';

void main() {
  setUpAll(() async {
    await Translations.load('en');
  });

  testWidgets('HabitNord home renders and add habit dialog opens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HabitNordRoot());
    expect(find.byKey(const Key('appBarTitle')), findsOneWidget);

    // Open add habit dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text(Translations.text('add_habit')), findsOneWidget);
  });
  testWidgets('App renders HabitNord home', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitNordRoot());

    expect(find.byKey(const Key('appBarTitle')), findsOneWidget);

    // Add habit dialog opens
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text(Translations.text('add_habit')), findsOneWidget);
  });
}
