import 'package:chat_app/features/auth/presentation/pages/signup_screen.dart';
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
  Future<void> registerUser({
    required String username,
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
        home: SignupScreen(),
      ),
    );
  }

  testWidgets('renders Create an account text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('renders Signup button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('renders three text form fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('renders Login text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('shows Username is required error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Username is required'), findsOneWidget);
  });

  testWidgets('shows Email is required error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('shows Password is required error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows invalid username error when less than 3 chars', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).at(0), 'ab');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Username must be at least 3 characters'), findsOneWidget);
  });

  testWidgets('shows invalid email error', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).at(1), 'invalid');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
  });

  testWidgets('shows invalid password error', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).at(2), 'pass');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Min 8 chars, uppercase, lowercase & number'), findsOneWidget);
  });
}
