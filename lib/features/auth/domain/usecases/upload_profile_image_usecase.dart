import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

class UploadProfileImageUseCase {
  final IAuthRepository repository;

  UploadProfileImageUseCase({required this.repository});

  Future<Either<Failure, String>> call(File file) async {
    return await repository.uploadProfileImage(file);
  }
}
