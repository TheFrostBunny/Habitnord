import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitnord/app_bar.dart';

class DummyHomeScreen extends StatelessWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'HabitNord'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: const Center(child: Text('Dummy')), // Minimal body
    );
  }
}

void main() {
  testWidgets('DummyHomeScreen shows app bar and add button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DummyHomeScreen()));
    await tester.pumpAndSettle();
    expect(find.text('HabitNord'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
