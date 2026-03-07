import 'package:chat_app/core/error/failures.dart';
import 'package:chat_app/core/services/connectivity/network_info.dart';
import 'package:chat_app/features/conversation/data/datasources/remote/conversation_remote_datasource.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chat_app/features/conversation/domain/entities/message_entity.dart';
import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationRepositoryProvider = Provider<IConversationRepository>((ref) {
  return ConversationRepositoryImpl(
    remoteDataSource: ref.read(conversationRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ConversationRepositoryImpl implements IConversationRepository {
  final IConversationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ConversationRepositoryImpl({
    required IConversationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createConversation(String userId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.createConversation(userId);
        return Right(result);
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to create conversation',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getAllConversations() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getAllConversations();
        return Right(result.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to get conversations',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(String conversationId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getMessages(conversationId);
        return Right(result.map((e) => e.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to get messages',
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(ApiFailure(message: 'No Internet Connection'));
    }
  }
}
