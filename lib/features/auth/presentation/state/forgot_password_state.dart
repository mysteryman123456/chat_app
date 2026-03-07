import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, loading, emailSent, success, error }

class ForgotPasswordState extends Equatable {
  final ForgotPasswordStatus status;
  final String? resetToken;  // token returned by backend after forgot-password
  final String? error;

  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.resetToken,
    this.error,
  });

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? resetToken,
    String? error,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      resetToken: resetToken ?? this.resetToken,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, resetToken, error];
}
