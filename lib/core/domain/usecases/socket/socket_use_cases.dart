import 'package:indriver_uber_clone/core/domain/usecases/socket/connect_socket_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/disconnect_socket_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/socket/send_socket_message_use_case.dart';

class SocketUseCases {
  SocketUseCases({
    required this.connectSocketUseCase,
    required this.disconnectSocketUseCase,
    required this.sendSocketMessageUseCase,
  });

  ConnectSocketUseCase connectSocketUseCase;
  DisconnectSocketUseCase disconnectSocketUseCase;
  SendSocketMessageUseCase sendSocketMessageUseCase;
}
