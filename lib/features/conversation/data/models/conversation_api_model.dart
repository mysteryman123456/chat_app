import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationApiModel {
  final String id;
  final String type;
  final String createdBy;
  final String? groupName;
  final List<String> participants;

  ConversationApiModel({
    required this.id,
    required this.type,
    required this.createdBy,
    this.groupName,
    required this.participants,
  });

  factory ConversationApiModel.fromJson(Map<String, dynamic> json) {
    // Backend aggregate returns "conversation_id" and "users" object array
    final id = json['conversation_id'] ?? json['_id'] ?? '';
    final type = json['type'] ?? 'SINGLE';
    final createdBy = json['created_by'] ?? '';
    final groupName = json['group_name'];
    
    List<String> participants = [];
    if (json['users'] != null) {
      final users = json['users'] as List;
      participants = users.map((u) => u['_id'] as String).toList();
    } else if (json['participants'] != null) {
      participants = List<String>.from(json['participants']);
    }

    return ConversationApiModel(
      id: id,
      type: type,
      createdBy: createdBy,
      groupName: groupName,
      participants: participants,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      type: type,
      createdBy: createdBy,
      groupName: groupName,
      participants: participants,
    );
  }
}
