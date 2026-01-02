import 'package:hive/hive.dart';

part "auth_hive_model.g.dart";

@HiveType(typeId: 0)
class AuthHiveModel {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String password;
  @HiveField(3)
  final String? username;
  @HiveField(4)
  final String? profilePircture;

  AuthHiveModel({
    required this.userId,
    required this.email,
    required this.password,
    this.username,
    this.profilePircture,
  });
}
