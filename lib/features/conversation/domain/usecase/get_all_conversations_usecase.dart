import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/app_usecase.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllConversationsUseCase implements UsecaseWithoutParms<List<ConversationEntity>> {
  final IConversationRepository repository;

  GetAllConversationsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ConversationEntity>>> call() {
    return repository.getAllConversations();
  }
}
