import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/services/connectivity/network_info.dart';
import 'package:chat_app/features/search/data/datasources/remote/search_remote_datasource.dart';
import 'package:chat_app/features/search/domain/entities/search_user_entity.dart';
import 'package:chat_app/features/search/domain/repository/search_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  return SearchRepositoryImpl(
    remoteDataSource: ref.read(searchRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class SearchRepositoryImpl implements ISearchRepository {
  final ISearchRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SearchRepositoryImpl({
    required ISearchRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers(String query) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.searchUsers(query);
        return Right(result.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to search users',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No Internet Connection'));
    }
  }
}
