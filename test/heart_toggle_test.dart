import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heart_toggle/heart_toggle.dart';

void main() {
  testWidgets('should pump and find heart toggle', (WidgetTester tester) async {
    var heartToggle = const HeartToggle();
    await tester.pumpWidget(heartToggle);
    final toggleFinder = find.byWidget(heartToggle);
    expect(toggleFinder, findsOneWidget);
  });
}
