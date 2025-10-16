import 'dart:async';
import 'dart:io';
import 'package:indriver_uber_clone/core/errors/exceptions.dart';
import 'package:indriver_uber_clone/core/errors/faliures.dart';

Failure mapExceptionToFailure(Object e) {
  if (e is ServerException) {
    return ServerFailure(message: e.message, statusCode: e.statusCode);
  } else if (e is TokenExpiredException) {
    //expired token — treat as server/auth failure
    return ServerFailure(message: e.message, statusCode: e.statusCode);
  } else if (e is CacheException) {
    return CacheFaliure(message: e.message, statusCode: e.statusCode);
  } else if (e is SocketException) {
    return const SocketFailure(
      message: 'No internet connection',
      statusCode: 503,
    );
  } else if (e is TimeoutException) {
    return const ServerFailure(message: 'Request timed out', statusCode: 408);
  } else {
    return ServerFailure(message: e.toString(), statusCode: 500);
  }
}
