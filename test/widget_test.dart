import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vidcollabadmin/main.dart';

void main() {
  testWidgets('shows a centered admin login form', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to VidCollab'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == 'Enter Email',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Enter Password',
      ),
      findsOneWidget,
    );
    expect(find.text('Request reset password'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
  });

  testWidgets('validates email and password before login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('opens signup form and validates required credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your admin account'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Create account'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('requires Firebase minimum password length for signup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == 'Enter Email',
      ),
      'admin@example.com',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Enter Password',
      ),
      'short',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });
}
