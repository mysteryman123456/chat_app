import 'package:chat_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Info: For use case with parameter
abstract interface class UseCaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

// Info: For use case without parameter
abstract interface class UseCaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}
