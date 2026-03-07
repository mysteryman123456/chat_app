import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(String userId, Map<String, dynamic> data) async {
    return await repository.updateProfile(userId, data);
  }
}
