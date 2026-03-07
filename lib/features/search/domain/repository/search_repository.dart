import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/features/search/domain/entities/search_user_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class ISearchRepository {
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers(String query);
}
