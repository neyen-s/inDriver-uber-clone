import 'package:equatable/equatable.dart';
import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';
import 'package:indriver_uber_clone/core/domain/repositories/client_request_repository.dart';
import 'package:indriver_uber_clone/core/utils/base_use_cases.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';

class GetTimeAndDistanceValuesUsecase
    extends UsecaseWithParams<void, TimeAndDistanceParams> {
  GetTimeAndDistanceValuesUsecase(this._repository);
  final ClientRequestRepository _repository;

  @override
  ResultFuture<TimeAndDistanceValuesEntity> call(TimeAndDistanceParams params) {
    return _repository.getTimeAndDistanceClientRequests(
      params.originLat,
      params.originLng,
      params.destinationLat,
      params.destinationLng,
    );
  }
}

class TimeAndDistanceParams extends Equatable {
  const TimeAndDistanceParams({
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
  });

  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;

  @override
  List<Object?> get props => [
    originLat,
    originLng,
    destinationLat,
    destinationLng,
  ];
}
