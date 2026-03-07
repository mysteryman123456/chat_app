
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? userId;
  final String username;
  final String email;
  final String? password;

  AuthApiModel({
    this.userId,
    required this.username,
    required this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) {
      data['password'] = password;
    }
    return data;
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userId: json['_id']?.toString(),
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      username: username,
      email: email,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      username: entity.username,
      email: entity.email,
      password: entity.password,
    );
  }
}