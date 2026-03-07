import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/services/connectivity/network_info.dart';
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
            message: e.response?.data['message'] ?? "Failed to login user!",
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
  Future<Either<Failure, bool>> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }


}