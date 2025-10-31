import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/auth/data/datasource/remote/user_dto.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

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
    int? tryInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    double tryDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0;
    }

    // Debug: imprime el json que se está parseando (quita en producción)
    // debugPrint('DriverTripRequestDTO.fromJson json: $json');

    final id = tryInt(json['id']);
    final idClientRequest = tryInt(json['id_client_request']);
    final idDriver = tryInt(json['id_driver']);
    final fare = tryDouble(json['fare_offered']);
    final timeVal = tryDouble(json['time']);
    final dist = tryDouble(json['distance']);

    if (idClientRequest == null || idDriver == null) {
      throw FormatException(
        'Missing required id_client_request or id_driver in'
        ' DriverTripRequestDTO: $json',
      );
    }

    DateTime? created;
    DateTime? updated;
    try {
      if (json['created_at'] != null) {
        created = DateTime.tryParse(json['created_at'].toString());
      }
    } catch (_) {
      created = null;
    }
    try {
      if (json['updated_at'] != null) {
        updated = DateTime.tryParse(json['updated_at'].toString());
      }
    } catch (_) {
      updated = null;
    }

    UserDTO? driverDto;
    try {
      final rawDriver = json['driver'];
      debugPrint(
        'Driver field runtimeType: ${rawDriver?.runtimeType} value: $rawDriver',
      );

      if (rawDriver != null && rawDriver is Map) {
        final driverMap = Map<String, dynamic>.from(rawDriver);
        driverDto = UserDTO.fromJson(driverMap);
      } else {
        driverDto = null;
      }
    } catch (e, st) {
      debugPrint(
        'Warning parsing driver field: $e — value: ${json['driver']} \n$st',
      );
      driverDto = null;
    }

    return DriverTripRequestDTO(
      id: id,
      idClientRequest: idClientRequest,
      idDriver: idDriver,
      fareOffered: fare,
      time: timeVal,
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
