import 'package:chat_app/features/auth/data/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:chat_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:chat_app/features/auth/presentation/state/forgot_password_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgotPasswordViewModelProvider =
    NotifierProvider<ForgotPasswordViewModel, ForgotPasswordState>(
        ForgotPasswordViewModel.new);

class ForgotPasswordViewModel extends Notifier<ForgotPasswordState> {
  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;

  @override
  ForgotPasswordState build() {
    final authRepository = ref.read(authRepositoryProvider);
    _forgotPasswordUseCase = ForgotPasswordUseCase(repository: authRepository);
    _resetPasswordUseCase = ResetPasswordUseCase(repository: authRepository);
    return const ForgotPasswordState();
  }

  /// Step 1: user enters their email; backend sends OTP and returns a token.
  Future<bool> requestOtp(String email) async {
    state = state.copyWith(status: ForgotPasswordStatus.loading, error: null);
    final result = await _forgotPasswordUseCase(email);
    return result.fold(
      (failure) {
        state = state.copyWith(
            status: ForgotPasswordStatus.error, error: failure.message);
        return false;
      },
      (token) {
        state = state.copyWith(
            status: ForgotPasswordStatus.emailSent, resetToken: token);
        return true;
      },
    );
  }

  /// Step 2: user enters the OTP they received and a new password.
  Future<bool> resetPassword(String otp, String newPassword) async {
    final token = state.resetToken;
    if (token == null) {
      state = state.copyWith(
          status: ForgotPasswordStatus.error,
          error: 'Session expired. Please request OTP again.');
      return false;
    }
    state = state.copyWith(status: ForgotPasswordStatus.loading, error: null);
    final result = await _resetPasswordUseCase(token, otp, newPassword);
    return result.fold(
      (failure) {
        state = state.copyWith(
            status: ForgotPasswordStatus.error, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(status: ForgotPasswordStatus.success);
        return true;
      },
    );
  }

  void reset() {
    state = const ForgotPasswordState();
  }
}
