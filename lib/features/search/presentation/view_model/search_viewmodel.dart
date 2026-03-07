import 'package:chat_app/features/search/data/repository/search_repository_impl.dart';
import 'package:chat_app/features/search/domain/usecase/search_user_usecase.dart';
import 'package:chat_app/features/search/presentation/state/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchUserUseCaseProvider = Provider<SearchUserUseCase>((ref) {
  return SearchUserUseCase(repository: ref.read(searchRepositoryProvider));
});

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  SearchViewModel.new,
);

class SearchViewModel extends Notifier<SearchState> {
  late final SearchUserUseCase _searchUserUseCase;

  @override
  SearchState build() {
    _searchUserUseCase = ref.read(searchUserUseCaseProvider);
    return const SearchState();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = const SearchState(status: SearchStatus.success, users: []);
      return;
    }
    
    state = state.copyWith(status: SearchStatus.loading);
    final result = await _searchUserUseCase(query);
    result.fold(
      (failure) => state = state.copyWith(
        status: SearchStatus.error,
        error: failure.message,
      ),
      (users) => state = state.copyWith(
        status: SearchStatus.success,
        users: users,
        error: null,
      ),
    );
  }
}
