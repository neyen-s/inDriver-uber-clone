import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

class DriverCarInfoDTO extends DriverCarInfoEntity {
  DriverCarInfoDTO({
    required super.brand,
    required super.color,
    required super.plate,
    super.idDriver,
  });

  factory DriverCarInfoDTO.fromEntity(DriverCarInfoEntity entity) {
    return DriverCarInfoDTO(
      idDriver: entity.idDriver,
      brand: entity.brand,
      color: entity.color,
      plate: entity.plate,
    );
  }

  factory DriverCarInfoDTO.fromJson(Map<String, dynamic> json) {
    return DriverCarInfoDTO(
      idDriver: json['id_driver'] != null
          ? (json['id_driver'] as num).toInt()
          : null,
      brand: json['brand'] as String,
      color: json['color'] as String,
      plate: json['plate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idDriver != null) 'id_driver': idDriver,
      'brand': brand,
      'color': color,
      'plate': plate,
    };
  }

  @override
  String toString() {
    return 'DriverCarInfoDto(idDriver: $idDriver, brand: $brand, '
        'color: $color, plate: $plate)';
  }
}
