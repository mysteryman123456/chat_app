import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/app_usecase.dart';
import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';
import 'package:dartz/dartz.dart';

class CreateConversationUseCase implements UsecaseWithParms<bool, String> {
  final IConversationRepository repository;

  CreateConversationUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(String userId) {
    return repository.createConversation(userId);
  }
}
