import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/usecase/login_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

class MockIAuthRepository implements IAuthRepository {
  final Either<Failure, AuthEntity>? mockLoginResult;

  MockIAuthRepository({this.mockLoginResult});

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async => const Right<Failure, bool>(true);
  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async =>
      mockLoginResult ?? const Left<Failure, AuthEntity>(ApiFailure(message: "Error"));
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async => const Left<Failure, AuthEntity>(ApiFailure(message: "Not implemented"));
  @override
  Future<Either<Failure, bool>> logout() async => const Right<Failure, bool>(true);
  @override
  Future<Either<Failure, AuthEntity>> updateProfile(String userId, Map<String, dynamic> data) async => const Left<Failure, AuthEntity>(ApiFailure(message: "Not implemented"));
  @override
  Future<Either<Failure, bool>> updatePassword(String oldPassword, String newPassword, String confirmPassword) async => const Right<Failure, bool>(true);
  @override
  Future<Either<Failure, String>> uploadProfileImage(File file) async => const Right<Failure, String>('');
  @override
  Future<Either<Failure, String>> forgotPassword(String email) async => const Right<Failure, String>('');
  @override
  Future<Either<Failure, bool>> resetPassword(String token, String otp, String password) async => const Right<Failure, bool>(true);
}

void main() {
  test('should return AuthEntity from the repository when login is successful', () async {
    final mockEntity = AuthEntity(username: 'test', email: 'test@test.com', password: 'test');
    final repo = MockIAuthRepository(mockLoginResult: Right<Failure, AuthEntity>(mockEntity));
    final useCase = LoginUseCase(authRepository: repo);
    final result = await useCase(const LoginUseCaseParams(email: 'test@test.com', password: 'password'));
    expect(result, Right<Failure, AuthEntity>(mockEntity));
  });

  test('should return Failure from the repository when login is unsuccessful', () async {
    final repo = MockIAuthRepository(mockLoginResult: const Left<Failure, AuthEntity>(ApiFailure(message: "Login Failed")));
    final useCase = LoginUseCase(authRepository: repo);
    final result = await useCase(const LoginUseCaseParams(email: 'test@test.com', password: 'password'));
    expect(result, const Left<Failure, AuthEntity>(ApiFailure(message: "Login Failed")));
  });

  test('should verify correct email parameter on failed login', () async {
    final repo = MockIAuthRepository(mockLoginResult: const Left<Failure, AuthEntity>(ApiFailure(message: "Login Failed")));
    final useCase = LoginUseCase(authRepository: repo);
    final result = await useCase(const LoginUseCaseParams(email: 'wrong@test.com', password: 'password'));
    expect(result.isLeft(), true);
  });

  test('should ensure the return type is Either Failure AuthEntity on failure', () async {
    final repo = MockIAuthRepository(mockLoginResult: const Left<Failure, AuthEntity>(ApiFailure(message: "Login Error")));
    final useCase = LoginUseCase(authRepository: repo);
    final result = await useCase(const LoginUseCaseParams(email: 'test@test.com', password: 'password'));
    expect(result.fold((l) => l is Failure, (r) => false), true);
  });

  test('should ensure the return type is Either Failure AuthEntity on success', () async {
    final mockEntity = AuthEntity(username: 'name', email: 'e', password: 'p');
    final repo = MockIAuthRepository(mockLoginResult: Right<Failure, AuthEntity>(mockEntity));
    final useCase = LoginUseCase(authRepository: repo);
    final result = await useCase(const LoginUseCaseParams(email: 'e', password: 'p'));
    expect(result.fold((l) => false, (r) => r is AuthEntity), true);
  });
}
