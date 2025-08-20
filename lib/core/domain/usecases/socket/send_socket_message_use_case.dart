import 'package:indriver_uber_clone/core/domain/repositories/socket_repository.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class SendSocketMessageUseCase {
  SendSocketMessageUseCase(this._socketRepository);

  final SocketRepository _socketRepository;

  ResultFuture<void> call(String event, Map<String, dynamic> data) =>
      _socketRepository.sendMessage(event, data);
}
