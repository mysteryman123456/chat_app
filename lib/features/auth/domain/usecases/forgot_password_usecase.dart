import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ForgotPasswordUseCase {
  final IAuthRepository repository;

  ForgotPasswordUseCase({required this.repository});

  /// Returns the reset token returned by the backend.
  Future<Either<Failure, String>> call(String email) async {
    return await repository.forgotPassword(email);
  }
}
