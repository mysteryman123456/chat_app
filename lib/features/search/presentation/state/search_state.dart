import 'package:chat_app/features/search/domain/entities/search_user_entity.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<SearchUserEntity> users;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.users = const [],
    this.error,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<SearchUserEntity>? users,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      users: users ?? this.users,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, users, error];
}
