import 'package:chat_app/core/api/api_client.dart';
import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/core/services/storage/user_session_service.dart';
import 'package:chat_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:chat_app/features/auth/data/models/auth_api_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

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
      final token = data['token'] as String;

      final user = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: user.userId ?? data['_id'] ?? '',
        email: user.email,
      );
      
      await _userSessionService.saveToken(token);

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

  @override
  Future<AuthApiModel> updateProfile(String userId, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiEndpoints.updateProfile}/$userId',
      data: data,
    );
    if (response.data['success'] == true) {
      final updatedData = response.data['data'] as Map<String, dynamic>;
      
      final user = AuthApiModel.fromJson(updatedData);
      
      // Update local session data with new info
      await _userSessionService.saveUserSession(
        userId: user.userId ?? updatedData['_id'] ?? userId,
        email: user.email,
      );
      
      return user;
    }
    throw Exception(response.data['message'] ?? 'Failed to update profile');
  }

  @override
  Future<bool> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
    final response = await _apiClient.patch(
      ApiEndpoints.updatePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? 'Failed to update password');
  }

  @override
  Future<String> uploadProfileImage(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadImage,
      formData: formData,
    );
    
    if (response.data['success'] == true) {
      return response.data['data']['file_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    if (response.data['success'] == true) {
      return response.data['data']['token'] as String;
    }
    throw Exception(response.data['message'] ?? 'Failed to send reset email');
  }

  @override
  Future<bool> resetPassword(String token, String otp, String password) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.resetPassword}?token=$token',
      data: {'otp': otp, 'password': password},
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? 'Failed to reset password');
  }
}