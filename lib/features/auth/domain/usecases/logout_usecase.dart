import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<Either<Failure, bool>> call() async {
    return await repository.logout();
  }
}
