import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

class DriverTripRequestEntity {
  DriverTripRequestEntity({
    required this.idClientRequest,
    required this.idDriver,
    required this.fareOffered,
    required this.time,
    required this.distance,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.carInfo,
  });
  final int? id;
  final int idClientRequest;
  final int idDriver;
  final double fareOffered;
  final double time;
  final double distance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserEntity? driver;
  final DriverCarInfoEntity? carInfo;

  DriverTripRequestEntity copyWith({
    int? id,
    int? idClientRequest,
    int? idDriver,
    double? fareOffered,
    double? time,
    double? distance,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserEntity? driver,
    DriverCarInfoEntity? carInfo,
  }) => DriverTripRequestEntity(
    id: id ?? this.id,
    idClientRequest: idClientRequest ?? this.idClientRequest,
    idDriver: idDriver ?? this.idDriver,
    fareOffered: fareOffered ?? this.fareOffered,
    time: time ?? this.time,
    distance: distance ?? this.distance,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    driver: driver ?? this.driver,
    carInfo: carInfo ?? this.carInfo,
  );

  @override
  String toString() {
    return 'DriverTripRequestEntity(id: $id, idClientRequest: $idClientRequest,'
        ' idDriver: $idDriver, fareOffered: $fareOffered, time: $time, '
        'distance: $distance, createdAt: $createdAt, updatedAt: $updatedAt,'
        ' driver: $driver carInfo: $carInfo)';
  }
}
