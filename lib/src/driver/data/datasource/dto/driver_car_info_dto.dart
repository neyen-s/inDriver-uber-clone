import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

class DriverCarInfoDto extends DriverCarInfoEntity {
  DriverCarInfoDto({
    required super.brand,
    required super.color,
    required super.plate,
    super.idDriver,
  });

  factory DriverCarInfoDto.fromEntity(DriverCarInfoEntity entity) {
    return DriverCarInfoDto(
      idDriver: entity.idDriver,
      brand: entity.brand,
      color: entity.color,
      plate: entity.plate,
    );
  }

  factory DriverCarInfoDto.fromJson(Map<String, dynamic> json) {
    return DriverCarInfoDto(
      //: json['id_driver'] as int,
      brand: json['brand'] as String,
      color: json['color'] as String,
      plate: json['plate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_driver': idDriver,
      'brand': brand,
      'color': color,
      'plate': plate,
    };
  }

  @override
  String toString() {
    return 'DriverCarInfoDto(idDriver: $idDriver, brand: $brand,'
        ' color: $color, plate: $plate)';
  }
}
