import 'package:chat_app/features/search/domain/entities/search_user_entity.dart';

class SearchUserApiModel {
  final String id;
  final String username;
  final String email;
  final String? profileImage;

  SearchUserApiModel({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
  });

  factory SearchUserApiModel.fromJson(Map<String, dynamic> json) {
    return SearchUserApiModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
    );
  }

  SearchUserEntity toEntity() {
    return SearchUserEntity(
      id: id,
      username: username,
      email: email,
      profileImage: profileImage,
    );
  }
}
