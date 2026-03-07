import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationApiModel {
  final String id;
  final String type;
  final String createdBy;
  final String? groupName;
  final List<String> participants;
  final String? otherUserName;
  final String? otherUserProfileImage;
  final String? otherUserId;

  ConversationApiModel({
    required this.id,
    required this.type,
    required this.createdBy,
    this.groupName,
    required this.participants,
    this.otherUserName,
    this.otherUserProfileImage,
    this.otherUserId,
  });

  factory ConversationApiModel.fromJson(Map<String, dynamic> json) {
    final id = json['conversation_id'] ?? json['_id'] ?? '';
    final type = json['type'] ?? 'SINGLE';
    final createdBy = json['created_by'] ?? '';
    final groupName = json['group_name'];

    List<String> participants = [];
    String? otherUserName;
    String? otherUserProfileImage;
    String? otherUserId;

    if (json['users'] != null) {
      final users = json['users'] as List;
      participants = users
          .map((u) => (u['_id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();

      // For SINGLE chats, the `users` array only contains the OTHER user
      if (users.isNotEmpty) {
        final other = users[0] as Map<String, dynamic>;
        otherUserId = (other['_id'] ?? '').toString();
        otherUserName = other['username'] as String?;
        otherUserProfileImage = other['profile_image'] as String?;
      }
    } else if (json['participants'] != null) {
      participants = List<String>.from(json['participants']);
    }

    return ConversationApiModel(
      id: id,
      type: type,
      createdBy: createdBy,
      groupName: groupName,
      participants: participants,
      otherUserName: otherUserName,
      otherUserProfileImage: otherUserProfileImage,
      otherUserId: otherUserId,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      type: type,
      createdBy: createdBy,
      groupName: groupName,
      participants: participants,
      otherUserName: otherUserName,
      otherUserProfileImage: otherUserProfileImage,
      otherUserId: otherUserId,
    );
  }
}
