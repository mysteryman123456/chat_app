import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';

class MessageApiModel {
  final String id;
  final String? conversationId;
  final String? senderId;
  final String type;
  final String? content;
  final String? fileUrl;
  final DateTime createdAt;

  MessageApiModel({
    required this.id,
    this.conversationId,
    this.senderId,
    required this.type,
    this.content,
    this.fileUrl,
    required this.createdAt,
  });

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    return MessageApiModel(
      id: json['_id'] ?? '',
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      type: json['type'] ?? 'TEXT',
      content: json['content'],
      fileUrl: json['file_url'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      content: content,
      fileUrl: fileUrl,
      createdAt: createdAt,
    );
  }
}
