import 'package:chat_app/core/api/api_client.dart';
import 'package:chat_app/core/api/api_endpoints.dart';
import 'package:chat_app/features/search/data/models/search_user_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRemoteDataSourceProvider = Provider<ISearchRemoteDataSource>((ref) {
  return SearchRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

abstract interface class ISearchRemoteDataSource {
  Future<List<SearchUserApiModel>> searchUsers(String query);
}

class SearchRemoteDataSource implements ISearchRemoteDataSource {
  final ApiClient _apiClient;

  SearchRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<SearchUserApiModel>> searchUsers(String query) async {
    final response = await _apiClient.get('${ApiEndpoints.searchUser}/$query');
    if (response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data.map((json) => SearchUserApiModel.fromJson(json)).toList();
    }
    throw Exception('Failed to search users');
  }
}
