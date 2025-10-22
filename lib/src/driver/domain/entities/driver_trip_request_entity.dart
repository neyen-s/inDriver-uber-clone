import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';

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
  );

  @override
  String toString() {
    return 'DriverTripRequestEntity(id: $id, idClientRequest: $idClientRequest,'
        ' idDriver: $idDriver, fareOffered: $fareOffered, time: $time, '
        'distance: $distance, createdAt: $createdAt, updatedAt: $updatedAt,'
        ' driver: $driver)';
  }
}
