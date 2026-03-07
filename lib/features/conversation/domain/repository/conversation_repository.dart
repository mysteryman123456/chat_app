import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class IConversationRepository {
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations();
  Future<Either<Failure, bool>> createConversation(String userId);
  Future<Either<Failure, List<MessageEntity>>> getMessages(String conversationId);
}
