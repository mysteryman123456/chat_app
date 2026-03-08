import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/auth/presentation/state/auth_state.dart';
import 'package:chat_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState();
  }

  @override
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {}
}

void main() {
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(MockAuthViewModel.new),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('renders Welcome Back text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('renders Sign In button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('renders two text form fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('renders Forgot Password text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('renders Signup text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Signup'), findsOneWidget);
  });

  testWidgets('shows Email is required error on empty email submitted', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows Password is required error on empty password submitted', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows invalid email error when email is malformed', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).first, 'test');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('shows invalid password error when password is short', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).last, 'pass');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Password must be 8+ chars with uppercase, lowercase & number'), findsOneWidget);
  });

  testWidgets('enters text successfully and no validation errors on valid input', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).first, 'test@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'Password123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsNothing);
  });
}
