import 'package:chat_app/core/api/api_client.dart';
import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/features/conversation/data/models/conversation_api_model.dart';
import 'package:chat_app/features/conversation/data/models/message_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationRemoteDataSourceProvider = Provider<IConversationRemoteDataSource>((ref) {
  return ConversationRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
  );
});

abstract interface class IConversationRemoteDataSource {
  Future<List<ConversationApiModel>> getAllConversations();
  Future<bool> createConversation(String userId);
  Future<List<MessageApiModel>> getMessages(String conversationId);
}

class ConversationRemoteDataSource implements IConversationRemoteDataSource {
  final ApiClient _apiClient;

  ConversationRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<ConversationApiModel>> getAllConversations() async {
    final response = await _apiClient.get(ApiEndpoints.getConversations);
    if (response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data.map((json) => ConversationApiModel.fromJson(json)).toList();
    }
    throw Exception('Failed to get conversations');
  }

  @override
  Future<bool> createConversation(String userId) async {
    final response = await _apiClient.post(
      ApiEndpoints.createConversation,
      data: {'type': 'SINGLE', 'user_id': userId},
    );
    if (response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data['message'] ?? 'Failed to create conversation');
  }

  @override
  Future<List<MessageApiModel>> getMessages(String conversationId) async {
    final response = await _apiClient.get('${ApiEndpoints.getMessages}/$conversationId');
    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => MessageApiModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        return []; // Handle empty or unexpected cases safely
      }
    }
    throw Exception('Failed to get messages');
  }
}
