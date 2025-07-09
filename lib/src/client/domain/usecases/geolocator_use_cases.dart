import 'package:indriver_uber_clone/src/client/domain/usecases/create_marker_use_case.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/find_position_use_case.dart';
import 'package:indriver_uber_clone/src/client/domain/usecases/get_marker_use_case.dart';

class GeolocatorUseCases {
  GeolocatorUseCases({
    required this.findPositionUseCase,
    required this.createMarkerUseCase,
    required this.getMarkerUseCase,
  });

  FindPositionUseCase findPositionUseCase;
  CreateMarkerUseCase createMarkerUseCase;
  GetMarkerUseCase getMarkerUseCase;
}
