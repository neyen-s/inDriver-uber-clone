import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class OnSocketMessageUseCase {
  OnSocketMessageUseCase(this._socketRepository);

  final SocketRepository _socketRepository;

  ResultFuture<Stream<dynamic>> call(String event) =>
      _socketRepository.onMessage(event);
}
