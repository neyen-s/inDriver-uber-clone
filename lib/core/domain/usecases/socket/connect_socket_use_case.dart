import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class ConnectSocketUseCase {
  ConnectSocketUseCase(this._socketRepository);

  final SocketRepository _socketRepository;

  ResultFuture<void> call() => _socketRepository.connect();
}
