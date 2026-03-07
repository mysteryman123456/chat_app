import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> updateProfile(String userId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> updatePassword(String oldPassword, String newPassword, String confirmPassword);
  Future<Either<Failure, String>> uploadProfileImage(File file);
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<Either<Failure, bool>> resetPassword(String token, String otp, String password);
}
