import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String type;
  final String createdBy;
  final String? groupName;
  final List<String> participants;
  // Info about the OTHER user in a 1-on-1 chat, from the `users` array
  final String? otherUserName;
  final String? otherUserProfileImage;
  final String? otherUserId;

  const ConversationEntity({
    required this.id,
    required this.type,
    required this.createdBy,
    this.groupName,
    required this.participants,
    this.otherUserName,
    this.otherUserProfileImage,
    this.otherUserId,
  });

  /// Display name shown in the conversation list / chat header
  String get displayName {
    if (type == 'GROUP') return groupName ?? 'Group Chat';
    return otherUserName ?? 'Unknown User';
  }

  /// First character initial for the avatar fallback
  String get initial {
    final name = displayName;
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
        id,
        type,
        createdBy,
        groupName,
        participants,
        otherUserName,
        otherUserProfileImage,
        otherUserId,
      ];
}
