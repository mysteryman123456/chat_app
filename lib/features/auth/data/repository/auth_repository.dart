import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/services/connectivity/network_info.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:chat_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:chat_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:chat_app/features/auth/data/models/auth_api_model.dart';
import 'package:chat_app/features/auth/data/models/auth_hive_model.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authLocalDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authLocalDatasource,
    required IAuthRemoteDataSource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDataSource = authLocalDatasource,
        _authRemoteDataSource = authRemoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(userModel);

        return Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Failed to register user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser = await _authLocalDataSource.getUserByEmail(
          user.email!,
        );

        if (existingUser != null) {
          return const Left(
            LocalDataBaseFailure(message: "This email has already been used!"),
          );
        }

        final userModel = AuthHiveModel.fromEntity(user);
        await _authLocalDataSource.register(userModel);

        return const Right(true);
      } catch (e) {
        return Left(LocalDataBaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email,
      String password,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = await _authRemoteDataSource.login(
          email,
          password,
        );

        if (userModel != null) {
          final entity = userModel.toEntity();
          return Right(entity);
        }

        return const Left(
          ApiFailure(message: "Email or password is incorrect!"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['error'] ?? "Failed to login user!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDataSource.login(email, password);

        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }

        return const Left(
          LocalDataBaseFailure(
            message: "Your email or password is incorrect, please try again!",
          ),
        );
      } catch (e) {
        return Left(LocalDataBaseFailure(message: e.toString()));
      }
    }
  }


  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // Typically, just clearing the local session is enough. Backends doing token blacklists might have a /logout endpoint.
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs: prefs);
      await userSessionService.clearSession();
      // AuthLocalDataSource might also need clearing if using hive heavily
      await _authLocalDataSource.logout();
      return const Right(true);
    } catch(e) {
      return Left(LocalDataBaseFailure(message: 'Failed to logout: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(String userId, Map<String, dynamic> data) async {
     if (await _networkInfo.isConnected) {
        try {
          final userModel = await _authRemoteDataSource.updateProfile(userId, data);
          return Right(userModel.toEntity());
        } on DioException catch (e) {
          return Left(
            ApiFailure(
              statusCode: e.response?.statusCode,
              message: e.response?.data['message'] ?? "Failed to update profile!",
            ),
          );
        } catch (e) {
             return Left(ApiFailure(message: e.toString()));
        }
     } else {
        return const Left(ApiFailure(message: "No internet connection"));
     }
  }

  @override
  Future<Either<Failure, bool>> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
      if (await _networkInfo.isConnected) {
        try {
          final success = await _authRemoteDataSource.updatePassword(oldPassword, newPassword, confirmPassword);
          return Right(success);
        } on DioException catch (e) {
          return Left(
            ApiFailure(
              statusCode: e.response?.statusCode,
              message: e.response?.data['message'] ?? "Failed to update password!",
            ),
          );
        } catch (e) {
             return Left(ApiFailure(message: e.toString()));
        }
     } else {
        return const Left(ApiFailure(message: "No internet connection"));
     }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File file) async {
      if (await _networkInfo.isConnected) {
        try {
          final url = await _authRemoteDataSource.uploadProfileImage(file);
          return Right(url);
        } on DioException catch (e) {
          return Left(
            ApiFailure(
              statusCode: e.response?.statusCode,
              message: e.response?.data['message'] ?? "Failed to upload image",
            ),
          );
        } catch (e) {
             return Left(ApiFailure(message: e.toString()));
        }
     } else {
        return const Left(ApiFailure(message: "No internet connection"));
     }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        final token = await _authRemoteDataSource.forgotPassword(email);
        return Right(token);
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to send reset email',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
      String token, String otp, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final success =
            await _authRemoteDataSource.resetPassword(token, otp, password);
        return Right(success);
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to reset password',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
  }
}