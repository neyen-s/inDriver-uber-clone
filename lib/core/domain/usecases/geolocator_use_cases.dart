import 'package:indriver_uber_clone/core/domain/usecases/create_marker_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/find_position_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/get_marker_use_case.dart';
import 'package:indriver_uber_clone/core/domain/usecases/get_position_stream_use_case.dart';

class GeolocatorUseCases {
  GeolocatorUseCases({
    required this.findPositionUseCase,
    required this.createMarkerUseCase,
    required this.getMarkerUseCase,
    required this.getPositionStreamUseCase,
  });

  FindPositionUseCase findPositionUseCase;
  CreateMarkerUseCase createMarkerUseCase;
  GetMarkerUseCase getMarkerUseCase;
  GetPositionStreamUseCase getPositionStreamUseCase;
}
