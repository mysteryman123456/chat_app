import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/usecase/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecase/register_usecase.dart';
import 'package:chat_app/features/auth/presentation/state/auth_state.dart';
import 'package:chat_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLoginUseCase implements LoginUseCase {
  final Either<Failure, AuthEntity> response;
  MockLoginUseCase(this.response);

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUseCaseParams params) async {
    return response;
  }
}

class MockRegisterUseCase implements RegisterUseCase {
  final Either<Failure, bool> response;
  MockRegisterUseCase(this.response);

  @override
  Future<Either<Failure, bool>> call(RegisterUseCaseParams params) async {
    return response;
  }
}

void main() {
  test('initial state should be initial', () {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Left(ApiFailure(message: '')))),
      ]
    );
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.initial);
  });

  test('successfully login sets state to authenticated', () async {
    final mockUser = AuthEntity(username: 'u', email: 'e', password: 'p');
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(Right(mockUser))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.loginUser(email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
  });

  test('successfully login sets user in state', () async {
    final mockUser = AuthEntity(username: 'u', email: 'e', password: 'p');
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(Right(mockUser))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.loginUser(email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.user, mockUser);
  });

  test('failing login sets state to error', () async {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: 'err')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.loginUser(email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
  });

  test('failing login sets error message', () async {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: 'err')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.loginUser(email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.error, 'err');
  });

  test('successfully register sets state to registered', () async {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.registerUser(username: 'u', email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.registered);
  });

  test('failing register sets state to error', () async {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Left(ApiFailure(message: 'failed_reg')))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    await viewModel.registerUser(username: 'u', email: 'e', password: 'p');
    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.error, 'failed_reg');
  });

  test('resetState sets state status to initial', () {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.resetState();
    var state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.initial);
  });

  test('resetState sets state error to null', () {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.resetState();
    var state = container.read(authViewModelProvider);
    expect(state.error, null);
  });

  test('clearError works properly', () {
    final container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(MockLoginUseCase(const Left(ApiFailure(message: '')))),
        registerUseCaseProvider.overrideWithValue(MockRegisterUseCase(const Right(true))),
      ]
    );
    final viewModel = container.read(authViewModelProvider.notifier);
    viewModel.clearError();
    var state = container.read(authViewModelProvider);
    expect(state.error, null);
  });
}
