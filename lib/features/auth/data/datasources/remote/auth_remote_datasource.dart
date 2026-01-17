import 'package:chat_app/core/api/api_client.dart';
import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:chat_app/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
        _userSessionService = userSessionService;



  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;

      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.userId!,
        email: user.email,
      );

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Registration failed');
  }

}