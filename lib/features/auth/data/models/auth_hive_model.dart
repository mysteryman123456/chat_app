import 'package:chat_app/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app/core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? profilePicture;


  AuthHiveModel({
    String? userId,
    required this.username,
    required this.email,
    this.password,
    this.profilePicture
  }) : userId = userId ?? const Uuid().v4();

  AuthEntity toEntity({AuthEntity? auth}) {
    return AuthEntity(
      userId: userId,
      username: username,
      email: email,
    );
  }

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId!,
      username: entity.username,
      email: entity.email,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}