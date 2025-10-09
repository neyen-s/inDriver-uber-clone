import 'dart:convert';

import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_request_entity.dart';

class DriverTripRequestDTO extends DriverTripRequestEntity {
  DriverTripRequestDTO({
    required super.idClientRequest,
    required super.idDriver,
    required super.fareOffered,
    required super.time,
    required super.distance,
    super.id,
    super.createdAt,
    super.updatedAt,
    UserDTO? super.driver,
  });

  factory DriverTripRequestDTO.fromEntity(DriverTripRequestEntity entity) {
    return DriverTripRequestDTO(
      idDriver: entity.idDriver,
      idClientRequest: entity.idClientRequest,
      fareOffered: entity.fareOffered,
      time: entity.time,
      distance: entity.distance,
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory DriverTripRequestDTO.fromJson(Map<String, dynamic> json) {
    final fare = (json['fare_offered'] as num?)?.toDouble() ?? 0.0;
    final dist = (json['distance'] as num?)?.toDouble() ?? 0.0;

    DateTime? created;
    DateTime? updated;
    try {
      created = json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null;
    } catch (_) {
      created = null;
    }
    try {
      updated = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null;
    } catch (_) {
      updated = null;
    }

    UserDTO? driverDto;
    if (json['driver'] != null && json['driver'] is Map<String, dynamic>) {
      driverDto = UserDTO.fromJson(json['driver'] as Map<String, dynamic>);
    }

    return DriverTripRequestDTO(
      id: json['id'] as int?,
      idClientRequest: json['id_client_request'] as int,
      idDriver: json['id_driver'] as int,
      fareOffered: fare,
      time: (json['time'] as double?) ?? 0,
      distance: dist,
      createdAt: created,
      updatedAt: updated,
      driver: driverDto,
    );
  }

  static List<DriverTripRequestDTO> driverTripRequestEntityFromJson(
    String str,
  ) => List<DriverTripRequestDTO>.from(
    (json.decode(str) as List<dynamic>).map(
      (x) => DriverTripRequestDTO.fromJson(x as Map<String, dynamic>),
    ),
  );

  static String driverTripRequestEntityToJson(
    List<DriverTripRequestDTO> data,
  ) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id_client_request': idClientRequest,
      'id_driver': idDriver,
      'fare_offered': fareOffered,
      'time': time,
      'distance': distance,
    };
    return map;
  }

  @override
  String toString() => 'DriverTripRequestDTO(${super.toString()})';
}
