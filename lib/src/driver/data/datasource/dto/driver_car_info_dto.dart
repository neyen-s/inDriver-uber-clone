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
    int? idDriver;
    try {
      if (json['id_driver'] != null) {
        final v = json['id_driver'];
        if (v is int) {
          idDriver = v;
        } else if (v is num) {
          idDriver = v.toInt();
        } else {
          idDriver = int.tryParse(v.toString());
        }
      }
    } catch (_) {
      idDriver = null;
    }

    final brand = (json['brand'] as String?) ?? '';
    final color = (json['color'] as String?) ?? '';
    final plate = (json['plate'] as String?) ?? '';

    return DriverCarInfoDTO(
      idDriver: idDriver,
      brand: brand,
      color: color,
      plate: plate,
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
