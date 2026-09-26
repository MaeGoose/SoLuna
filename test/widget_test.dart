import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Replace 'soluna' below with whatever `name:` is set to in your
// pubspec.yaml, if it's different.
import 'package:soluna/main.dart';

void main() {
  testWidgets('Create Account screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SoLunaApp());

    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}
