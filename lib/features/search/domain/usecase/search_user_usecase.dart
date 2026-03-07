import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/usecases/app_usecase.dart';
import 'package:chat_app/features/search/domain/entities/search_user_entity.dart';
import 'package:chat_app/features/search/domain/repository/search_repository.dart';
import 'package:dartz/dartz.dart';

class SearchUserUseCase implements UsecaseWithParms<List<SearchUserEntity>, String> {
  final ISearchRepository repository;

  SearchUserUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SearchUserEntity>>> call(String query) {
    return repository.searchUsers(query);
  }
}
