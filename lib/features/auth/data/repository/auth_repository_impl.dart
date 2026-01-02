import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/services/hive/hive_storage.dart';
import 'package:chat_app/features/auth/data/models/auth_hive_model.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements IAuthRepository {
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // Check if user already exists
      final existingUser = HiveStorage.getUser();
      if (existingUser != null && existingUser.email == entity.email) {
        return const Left(LocalDataBaseFailure(
          message: "User with this email already exists",
        ));
      }

      // Generate user ID
      const uuid = Uuid();
      final userId = uuid.v4();

      // Create auth model
      final authModel = AuthHiveModel(
        userId: userId,
        email: entity.email,
        password: entity.password ?? '',
        username: entity.username,
        profilePircture: entity.profilePicture,
      );

      // Save user
      await HiveStorage.saveUser(authModel);

      return const Right(true);
    } catch (e) {
      return Left(LocalDataBaseFailure(
        message: "Registration failed: ${e.toString()}",
      ));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = HiveStorage.getUser();

      if (user == null) {
        return const Left(LocalDataBaseFailure(
          message: "No user found. Please sign up first.",
        ));
      }

      if (user.email != email || user.password != password) {
        return const Left(LocalDataBaseFailure(
          message: "Invalid email or password",
        ));
      }

      // Convert to entity
      final authEntity = AuthEntity(
        userId: user.userId,
        email: user.email,
        username: user.username ?? user.email.split('@')[0],
        password: user.password,
        profilePicture: user.profilePircture,
      );

      return Right(authEntity);
    } catch (e) {
      return Left(LocalDataBaseFailure(
        message: "Login failed: ${e.toString()}",
      ));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = HiveStorage.getUser();

      if (user == null) {
        return const Left(LocalDataBaseFailure(
          message: "No user found",
        ));
      }

      // Convert to entity
      final authEntity = AuthEntity(
        userId: user.userId,
        email: user.email,
        username: user.username ?? user.email.split('@')[0],
        password: user.password,
        profilePicture: user.profilePircture,
      );

      return Right(authEntity);
    } catch (e) {
      return Left(LocalDataBaseFailure(
        message: "Failed to get current user: ${e.toString()}",
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await HiveStorage.clearUser();
      return const Right(true);
    } catch (e) {
      return Left(LocalDataBaseFailure(
        message: "Logout failed: ${e.toString()}",
      ));
    }
  }
}

