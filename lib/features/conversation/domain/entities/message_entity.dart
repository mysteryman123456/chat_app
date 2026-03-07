import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String? conversationId;
  final String? senderId;
  final String type; // "TEXT", "VIDEO", "IMAGE", "AUDIO", "FILE"
  final String? content;
  final String? fileUrl;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    this.conversationId,
    this.senderId,
    required this.type,
    this.content,
    this.fileUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        type,
        content,
        fileUrl,
        createdAt,
      ];
}
