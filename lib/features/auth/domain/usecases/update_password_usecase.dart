import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdatePasswordUseCase {
  final IAuthRepository repository;

  UpdatePasswordUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String oldPassword, String newPassword, String confirmPassword) async {
    return await repository.updatePassword(oldPassword, newPassword, confirmPassword);
  }
}
