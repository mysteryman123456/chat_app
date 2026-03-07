import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/app_usecase.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';
import 'package:dartz/dartz.dart';

class GetMessagesUseCase implements UsecaseWithParms<List<MessageEntity>, String> {
  final IConversationRepository repository;

  GetMessagesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MessageEntity>>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}
