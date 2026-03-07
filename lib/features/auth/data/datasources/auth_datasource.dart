

import 'package:chat_app/features/auth/data/models/auth_api_model.dart';
import 'dart:io';
import 'package:chat_app/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<AuthHiveModel?> getUserById(String authId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String authId);
  Future<bool> isEmailExists(String email);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> updateProfile(String userId, Map<String, dynamic> data);
  Future<bool> updatePassword(String oldPassword, String newPassword, String confirmPassword);
  Future<String> uploadProfileImage(File file);
  Future<String> forgotPassword(String email);
  Future<bool> resetPassword(String token, String otp, String password);
}