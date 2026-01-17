
import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? userId;
  final String email;
  final String username;
  final String? password;

  AuthApiModel({this.userId, required this.email, this.password, required this.username});

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password, "username": username};
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['passwordHash'] as String?,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(username: username, email :email, password: password);
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      email: entity.email,
      password: entity.password,
      username: entity.username,
    );
  }
}