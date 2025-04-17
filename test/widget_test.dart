import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:member_staff_app/src/app.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MemberStaffApp());

    // Verify that the app title is displayed.
    expect(find.text('Member Staff App'), findsOneWidget);
  });
}
