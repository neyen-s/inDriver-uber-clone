import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode})
    : assert(
        statusCode is int || statusCode is String,
        ' statusCode must be an int or a String',
      );
  final String message;
  final dynamic statusCode;

  String get errorMessage =>
      '$statusCode ${statusCode is String ? '' : 'Error'}: $message';

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFaliure extends Failure {
  const CacheFaliure({required super.message, required super.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.statusCode});

  ServerFailure.fromException(ServerException exception)
    : this(message: exception.message, statusCode: exception.statusCode);
}
