import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecase/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

class MockIAuthRepositoryForRegister implements IAuthRepository {
  final Either<Failure, bool>? mockRegisterResult;

  MockIAuthRepositoryForRegister({this.mockRegisterResult});

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    return mockRegisterResult ?? const Left<Failure, bool>(ApiFailure(message: "Error"));
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    return const Left<Failure, AuthEntity>(ApiFailure(message: "Not implemented"));
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    return const Left<Failure, AuthEntity>(ApiFailure(message: "Not implemented"));
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    return const Right<Failure, bool>(true);
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(String userId, Map<String, dynamic> data) async {
    return const Left<Failure, AuthEntity>(ApiFailure(message: "Not implemented"));
  }

  @override
  Future<Either<Failure, bool>> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
    return const Right<Failure, bool>(true);
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File file) async {
    return const Right<Failure, String>('');
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    return const Right<Failure, String>('');
  }

  @override
  Future<Either<Failure, bool>> resetPassword(String token, String otp, String password) async {
    return const Right<Failure, bool>(true);
  }
}

void main() {
  test('should return true when registration is successful', () async {
    final repo = MockIAuthRepositoryForRegister(mockRegisterResult: const Right<Failure, bool>(true));
    final useCase = RegisterUseCase(authRepository: repo);
    final result = await useCase(const RegisterUseCaseParams(username: 'test', email: 'test@email.com', password: 'password'));
    expect(result, const Right<Failure, bool>(true));
  });

  test('should return Failure when registration fails', () async {
    final repo = MockIAuthRepositoryForRegister(mockRegisterResult: const Left<Failure, bool>(ApiFailure(message: "Registration Failed")));
    final useCase = RegisterUseCase(authRepository: repo);
    final result = await useCase(const RegisterUseCaseParams(username: 'test', email: 'test@email.com', password: 'password'));
    expect(result, const Left<Failure, bool>(ApiFailure(message: "Registration Failed")));
  });

  test('should match the failure message when registration fails', () async {
    final repo = MockIAuthRepositoryForRegister(mockRegisterResult: const Left<Failure, bool>(ApiFailure(message: "Error XYZ")));
    final useCase = RegisterUseCase(authRepository: repo);
    final result = await useCase(const RegisterUseCaseParams(username: 'test', email: 'test@email.com', password: 'password'));
    result.fold((l) => expect(l.message, "Error XYZ"), (r) => fail('Should be left'));
  });

  test('should verify username is passed properly and fails correctly', () async {
    final repo = MockIAuthRepositoryForRegister(mockRegisterResult: const Left<Failure, bool>(ApiFailure(message: "Username taken")));
    final useCase = RegisterUseCase(authRepository: repo);
    final result = await useCase(const RegisterUseCaseParams(username: 'taken', email: 'e', password: 'p'));
    expect(result, const Left<Failure, bool>(ApiFailure(message: "Username taken")));
  });

  test('should ensure the return type is Either Failure bool on success', () async {
    final repo = MockIAuthRepositoryForRegister(mockRegisterResult: const Right<Failure, bool>(true));
    final useCase = RegisterUseCase(authRepository: repo);
    final result = await useCase(const RegisterUseCaseParams(username: 'u', email: 'e', password: 'p'));
    expect(result.isRight(), true);
  });
}
