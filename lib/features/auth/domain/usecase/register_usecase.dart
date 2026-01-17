import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/app_usecase.dart';
import 'package:chat_app/features/auth/data/repository/auth_repository.dart';
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:chat_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RegisterUseCaseParams extends Equatable {
  final String username;
  final String email;
  final String password;

  const RegisterUseCaseParams({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email,  password];
}

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase implements UsecaseWithParms<bool, RegisterUseCaseParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUseCaseParams params) {
    final authEntity = AuthEntity(
      username: params.username,
      email: params.email,
      password: params.password,
    );

    return _authRepository.register(authEntity);
  }
}