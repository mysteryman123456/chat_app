import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:equatable/equatable.dart';

enum ConversationStatus { initial, loading, success, error }

class ConversationState extends Equatable {
  final ConversationStatus status;
  final List<ConversationEntity> conversations;
  final List<MessageEntity> messages;
  final String? error;

  const ConversationState({
    this.status = ConversationStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.error,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    List<ConversationEntity>? conversations,
    List<MessageEntity>? messages,
    String? error,
  }) {
    return ConversationState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, conversations, messages, error];
}
