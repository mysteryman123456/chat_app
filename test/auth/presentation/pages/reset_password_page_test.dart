import 'package:chat_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:chat_app/features/auth/presentation/state/forgot_password_state.dart';
import 'package:chat_app/features/auth/presentation/view_model/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockForgotPasswordViewModel extends ForgotPasswordViewModel {
  @override
  ForgotPasswordState build() {
    return const ForgotPasswordState();
  }

  @override
  Future<bool> resetPassword(String otp, String newPassword) async {
    return true;
  }
}

void main() {
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        forgotPasswordViewModelProvider.overrideWith(MockForgotPasswordViewModel.new),
      ],
      child: const MaterialApp(
        home: ResetPasswordPage(),
      ),
    );
  }

  testWidgets('renders Reset Password text', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Reset Password'), findsWidgets);
  });

  testWidgets('renders Reset Password button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('renders OTP Field label', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('OTP Code'), findsOneWidget);
  });

  testWidgets('renders New Password label', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('New Password'), findsOneWidget);
  });

  testWidgets('renders Confirm Password label', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('shows OTP is required error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('OTP is required'), findsOneWidget);
  });

  testWidgets('shows Password is required error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows Please confirm password error on empty submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Please confirm password'), findsOneWidget);
  });

  testWidgets('shows Password must be at least 8 characters error', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('shows Passwords do not match error', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password124');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
