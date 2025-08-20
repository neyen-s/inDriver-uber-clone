import 'package:indriver_uber_clone/core/utils/typedefs.dart';

abstract class SocketRepository {
  ResultFuture<void> connect();

  ResultFuture<void> disconnect();

  ResultFuture<void> sendMessage(String event, dynamic data);

  ResultFuture<Stream<dynamic>> onMessage(String event);
}
