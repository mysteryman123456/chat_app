import 'package:chat_app/features/auth/domain/usecase/login_usecase.dart';
import 'package:chat_app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:chat_app/features/auth/domain/usecase/register_usecase.dart';
import 'package:chat_app/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUseCase _loginUseCase;
  late final LogoutUsecase _logoutUseCase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUseCaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const AuthState();
  }

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    await Future.delayed(Duration(seconds: 2));

    final result = await _registerUseCase(
      RegisterUseCaseParams(
        username: username,
        email: email,
        password: password
      ),
    );

    result.fold(
          (failure) => state = state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      ),
          (success) => state = state.copyWith(
        status: AuthStatus.registered,
        error: null,
      ),
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    await Future.delayed(Duration(seconds: 2));

    final result = await _loginUseCase(
      LoginUseCaseParams(email: email, password: password),
    );

    result.fold(
          (failure) => state = state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      ),
          (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      ),
    );
  }


  Future<void> logoutUser() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _logoutUseCase();

    result.fold(
          (failure) => state = state.copyWith(
        status: AuthStatus.error,
        error: failure.message,
      ),
          (success) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      ),
    );
  }

  void resetState() {
    state = const AuthState(status: AuthStatus.initial, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}