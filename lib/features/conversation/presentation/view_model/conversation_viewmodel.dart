import 'package:chat_app/features/conversation/data/repository/conversation_repository_impl.dart';
import 'package:chat_app/features/conversation/domain/usecase/create_conversation_usecase.dart';
import 'package:chat_app/features/conversation/domain/usecase/get_all_conversations_usecase.dart';
import 'package:chat_app/features/conversation/domain/usecase/get_messages_usecase.dart';
import 'package:chat_app/features/conversation/presentation/state/conversation_state.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllConversationsUseCaseProvider = Provider<GetAllConversationsUseCase>((ref) {
  return GetAllConversationsUseCase(repository: ref.read(conversationRepositoryProvider));
});

final createConversationUseCaseProvider = Provider<CreateConversationUseCase>((ref) {
  return CreateConversationUseCase(repository: ref.read(conversationRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(repository: ref.read(conversationRepositoryProvider));
});

final conversationViewModelProvider = NotifierProvider<ConversationViewModel, ConversationState>(
  ConversationViewModel.new,
);

class ConversationViewModel extends Notifier<ConversationState> {
  late final GetAllConversationsUseCase _getAllConversationsUseCase;
  late final CreateConversationUseCase _createConversationUseCase;
  late final GetMessagesUseCase _getMessagesUseCase;

  @override
  ConversationState build() {
    _getAllConversationsUseCase = ref.read(getAllConversationsUseCaseProvider);
    _createConversationUseCase = ref.read(createConversationUseCaseProvider);
    _getMessagesUseCase = ref.read(getMessagesUseCaseProvider);
    return const ConversationState();
  }

  Future<void> fetchConversations() async {
    state = state.copyWith(status: ConversationStatus.loading);
    final result = await _getAllConversationsUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationStatus.error,
        error: failure.message,
      ),
      (conversations) => state = state.copyWith(
        status: ConversationStatus.success,
        conversations: conversations,
        error: null,
      ),
    );
  }

  Future<bool> createConversation(String userId) async {
    state = state.copyWith(status: ConversationStatus.loading);
    final result = await _createConversationUseCase(userId);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ConversationStatus.error,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(status: ConversationStatus.success, error: null);
        fetchConversations(); // Refresh list
        return true;
      },
    );
  }

  Future<void> fetchMessages(String conversationId) async {
    state = state.copyWith(status: ConversationStatus.loading);
    final result = await _getMessagesUseCase(conversationId);
    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationStatus.error,
        error: failure.message,
      ),
      (messages) => state = state.copyWith(
        status: ConversationStatus.success,
        messages: messages,
        error: null,
      ),
    );
  }

  void addLocalMessage(MessageEntity message) {
    if (!state.messages.any((m) => m.id == message.id)) {
      state = state.copyWith(
        messages: List.from(state.messages)..insert(0, message),
      );
    }
  }
}

