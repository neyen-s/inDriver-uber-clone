import 'package:indriver_uber_clone/src/driver/domain/entities/driver_position_entity.dart';

class DriverPositionDTO extends DriverPositionEntity {
  DriverPositionDTO({
    required super.idDriver,
    required super.lat,
    required super.lng,
  });

  factory DriverPositionDTO.fromEntity(DriverPositionEntity entity) {
    return DriverPositionDTO(
      idDriver: entity.idDriver,
      lat: entity.lat,
      lng: entity.lng,
    );
  }
  factory DriverPositionDTO.fromJson(Map<String, dynamic> json) {
    return DriverPositionDTO(
      idDriver: json['id_driver'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_driver': idDriver, 'lat': lat, 'lng': lng};
  }

  @override
  String toString() =>
      'DriverPositionDto(idDriver: $idDriver, lat: $lat, lng: $lng)';
}
