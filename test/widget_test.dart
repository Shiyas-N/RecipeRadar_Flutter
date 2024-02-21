// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_radar/main.dart';

void main() {
  testWidgets('Navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the initial page is the LoginSignupPage
    expect(find.text('Login / Sign Up'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);

    // You can add further tests for navigation, etc., based on your app's logic
  });
}
