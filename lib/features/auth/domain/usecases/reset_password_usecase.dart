import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPasswordUseCase {
  final IAuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  /// [token] - token returned by forgot-password endpoint (passed as query param)
  /// [otp]   - one-time code sent to the user's email
  /// [password] - the new password to set
  Future<Either<Failure, bool>> call(
      String token, String otp, String password) async {
    return await repository.resetPassword(token, otp, password);
  }
}
