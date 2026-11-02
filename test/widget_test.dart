// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:daily_mate/app.dart';

void main() {
  testWidgets('splash screen navigates to home', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyMateApp());

    expect(find.text('DailyMate'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Good Morning!'), findsOneWidget);
  });
}
