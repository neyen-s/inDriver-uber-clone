import 'dart:convert';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class ClientRequestResponseDto extends ClientRequestResponseEntity {
  ClientRequestResponseDto({
    required super.id,
    required super.idClient,
    required super.fareOffered,
    required super.pickupDescription,
    required super.destinationDescription,
    required super.status,
    required super.updatedAt,
    required super.pickupPosition,
    required super.destinationPosition,
    required super.client,
    super.timeDifference,
    super.distance,
    super.driver,
    super.googleDistanceMatrix,
    super.idDriver,
    super.fareAssigned,
    super.carInfo,
  });

  factory ClientRequestResponseDto.fromJson(Map<String, dynamic> json) {
    // helpers
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    // required fields (be defensive: throw only on truly missing minimal ones)
    final id = _toInt(json['id']);
    final idClient = _toInt(json['id_client']);
    final fareOffered = _toDouble(json['fare_offered']);

    if (id == null || idClient == null || fareOffered == null) {
      throw Exception(
        'ClientRequestResponseDto.fromJson: missing required fields id/id_client/fare_offered',
      );
    }

    // updatedAt
    DateTime updatedAt;
    final rawUpdated = json['updated_at'];
    if (rawUpdated is String) {
      updatedAt = DateTime.tryParse(rawUpdated) ?? DateTime.now();
    } else if (rawUpdated is DateTime) {
      updatedAt = rawUpdated;
    } else {
      updatedAt = DateTime.now();
    }

    // Position parsing (defensive)
    PositionDto parsePos(dynamic posRaw) {
      if (posRaw is Map<String, dynamic>) {
        return PositionDto.fromJson(posRaw);
      }
      if (posRaw is String) {
        try {
          final m = jsonDecode(posRaw) as Map<String, dynamic>;
          return PositionDto.fromJson(m);
        } catch (_) {
          throw Exception('pickup/destination position invalid: $posRaw');
        }
      }
      throw Exception('pickup/destination position invalid: $posRaw');
    }

    // client
    ClientDto client;
    try {
      final clientMap = json['client'];
      if (clientMap is Map<String, dynamic>) {
        client = ClientDto.fromJson(clientMap);
      } else if (clientMap is String) {
        client = ClientDto.fromJson(
          jsonDecode(clientMap) as Map<String, dynamic>,
        );
      } else {
        client = ClientDto(name: '', image: '', phone: '', lastname: '');
      }
    } catch (_) {
      client = ClientDto(name: '', image: '', phone: '', lastname: '');
    }

    // optional googleDistanceMatrix
    GoogleDistanceMatrixDto? googleDistance;
    final gdmRaw = json['google_distance_matrix'];
    if (gdmRaw is Map<String, dynamic>) {
      try {
        googleDistance = GoogleDistanceMatrixDto.fromJson(gdmRaw);
      } catch (_) {
        googleDistance = null;
      }
    }

    // fareAssigned
    final fareAssigned = _toDouble(
      json['fare_assigned'] ?? json['fareAssigned'],
    );

    // ATTENTION HERE: backend uses id_driver_assigned in some endpoints
    final idDriver = _toInt(
      json['id_driver_assigned'] ?? json['id_driver'] ?? json['idDriver'],
    );

    // driver object (optional)
    ClientDto? driver;
    try {
      final driverMap = json['driver'];
      if (driverMap is Map<String, dynamic>) {
        driver = ClientDto.fromJson(driverMap);
      } else if (driverMap is String) {
        driver = ClientDto.fromJson(
          jsonDecode(driverMap) as Map<String, dynamic>,
        );
      } else {
        driver = null;
      }
    } catch (_) {
      driver = null;
    }

    // car info (defensive)
    DriverCarInfoDTO? carInfo;
    try {
      final rawCar = json['car'];
      if (rawCar is Map<String, dynamic>) {
        carInfo = DriverCarInfoDTO.fromJson(rawCar);
      } else if (rawCar is String) {
        carInfo = DriverCarInfoDTO.fromJson(
          jsonDecode(rawCar) as Map<String, dynamic>,
        );
      } else {
        carInfo = null;
      }
    } catch (_) {
      carInfo = null;
    }

    return ClientRequestResponseDto(
      id: id,
      idClient: idClient,
      fareOffered: fareOffered,
      pickupDescription: (json['pickup_description'] as String?) ?? '',
      destinationDescription:
          (json['destination_description'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      updatedAt: updatedAt,
      pickupPosition: parsePos(json['pickup_position']),
      destinationPosition: parsePos(json['destination_position']),
      client: client,
      timeDifference: _toInt(json['time_difference']),
      distance: _toDouble(json['distance']),
      driver: driver,
      googleDistanceMatrix: googleDistance,
      idDriver: idDriver,
      fareAssigned: fareAssigned,
      carInfo: carInfo,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'id_client': idClient,
    'fare_offered': fareOffered,
    'pickup_description': pickupDescription,
    'destination_description': destinationDescription,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'pickup_position': (pickupPosition is PositionDto)
        ? (pickupPosition as PositionDto).toJson()
        : {'x': pickupPosition.lng, 'y': pickupPosition.lat},
    'destination_position': (destinationPosition is PositionDto)
        ? (destinationPosition as PositionDto).toJson()
        : {'x': destinationPosition.lng, 'y': destinationPosition.lat},
    'distance': distance,
    'time_difference': timeDifference,
    'client': (client is ClientDto)
        ? (client as ClientDto).toMap()
        : {
            'name': client.name,
            'image': client.image,
            'phone': client.phone,
            'lastname': client.lastname,
          },
    'google_distance_matrix': (googleDistanceMatrix is GoogleDistanceMatrixDto)
        ? (googleDistanceMatrix! as GoogleDistanceMatrixDto).toJson()
        : null,
    'fare_assigned': fareAssigned,
    // export both keys so backend/frontend puedan usar el que esperan
    if (idDriver != null) ...{
      'id_driver': idDriver,
      'id_driver_assigned': idDriver,
    },
    'car': (carInfo is DriverCarInfoDTO)
        ? (carInfo as DriverCarInfoDTO).toJson()
        : null,
    'driver': (driver is ClientDto) ? (driver as ClientDto).toMap() : null,
  };

  factory ClientRequestResponseDto.fromEntity(
    ClientRequestResponseEntity entity,
  ) {
    return ClientRequestResponseDto(
      id: entity.id,
      idClient: entity.idClient,
      fareOffered: entity.fareOffered,
      pickupDescription: entity.pickupDescription,
      destinationDescription: entity.destinationDescription,
      status: entity.status,
      updatedAt: entity.updatedAt,
      pickupPosition: entity.pickupPosition,
      destinationPosition: entity.destinationPosition,
      distance: entity.distance,
      timeDifference: entity.timeDifference,
      client: entity.client,
      googleDistanceMatrix: entity.googleDistanceMatrix,
      idDriver: entity.idDriver,
      fareAssigned: entity.fareAssigned,
      carInfo: entity.carInfo,
      driver: entity.driver,
    );
  }
  static List<ClientRequestResponseDto> listFromJson(List<dynamic> json) => json
      .map((e) => ClientRequestResponseDto.fromJson(e as Map<String, dynamic>))
      .toList();
  /*   Map<String, dynamic> toJson() => {
    'id': id,
    'id_client': idClient,
    'fare_offered': fareOffered,
    'pickup_description': pickupDescription,
    'destination_description': destinationDescription,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'pickup_position': (pickupPosition is PositionDto)
        ? (pickupPosition as PositionDto).toJson()
        : {'x': pickupPosition.x, 'y': pickupPosition.y},
    'destination_position': (destinationPosition is PositionDto)
        ? (destinationPosition as PositionDto).toJson()
        : {'x': destinationPosition.x, 'y': destinationPosition.y},
    'distance': distance,
    'time_difference': timeDifference,
    'client': (client is ClientDto)
        ? (client as ClientDto).toMap()
        : {
            'name': client.name,
            'image': client.image,
            'phone': client.phone,
            'lastname': client.lastname,
          },
    'google_distance_matrix': (googleDistanceMatrix is GoogleDistanceMatrixDto)
        ? (googleDistanceMatrix! as GoogleDistanceMatrixDto).toJson()
        : {
            'distance': {
              'text': googleDistanceMatrix?.distance.text,
              'value': googleDistanceMatrix?.distance.value,
            },
            'duration': {
              'text': googleDistanceMatrix?.duration.text,
              'value': googleDistanceMatrix?.duration.value,
            },
            'status': googleDistanceMatrix?.status,
          },
    'fare_assissigned': fareAssigned,
    'id_driver': idDriver,
    'car': (carInfo is DriverCarInfoDTO)
        ? (carInfo as DriverCarInfoDTO).toJson()
        : {},
    'driver': (driver is ClientDto)
        ? (driver as ClientDto).toMap()
        : {
            'name': driver?.name,
            'image': driver?.image,
            'phone': driver?.phone,
            'lastname': driver?.lastname,
          },
  }; */
}

class ClientDto extends ClientEntity {
  ClientDto({
    required super.name,
    required super.image,
    required super.phone,
    required super.lastname,
  });

  factory ClientDto.fromJson(Map<String, dynamic> json) {
    return ClientDto(
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'phone': phone,
      'lastname': lastname,
    };
  }

  String toJson() => json.encode(toMap());

  ClientEntity toEntity() {
    return ClientEntity(
      name: name,
      image: image,
      phone: phone,
      lastname: lastname,
    );
  }
}

class PositionDto extends PositionEntity {
  PositionDto({required super.lng, required super.lat});

  factory PositionDto.fromJson(Map<String, dynamic> json) {
    final xNum = json['x'] ?? json['lat'] ?? json['latitude'];
    final yNum = json['y'] ?? json['lng'] ?? json['longitude'];

    return PositionDto(
      lng: (xNum is num) ? xNum.toDouble() : double.parse('$xNum'),
      lat: (yNum is num) ? yNum.toDouble() : double.parse('$yNum'),
    );
  }
  PositionEntity toEntity() {
    return PositionEntity(lng: lng, lat: lat);
  }

  Map<String, dynamic> toJson() => {'x': lng, 'y': lat};

  @override
  String toString() => 'PositionEntity(x: $lng, y: $lat)';
}

class GoogleDistanceMatrixDto extends GoogleDistanceMatrixEntity {
  GoogleDistanceMatrixDto({
    required super.distance,
    required super.duration,
    required super.status,
  });

  factory GoogleDistanceMatrixDto.fromJson(Map<String, dynamic> json) {
    return GoogleDistanceMatrixDto(
      distance: DistanceDto.fromJson(json['distance'] as Map<String, dynamic>),
      duration: DistanceDto.fromJson(json['duration'] as Map<String, dynamic>),
      status: json['status'] as String? ?? '',
    );
  }
  GoogleDistanceMatrixEntity toEntity() {
    return GoogleDistanceMatrixEntity(
      distance: distance,
      duration: duration,
      status: status,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'distance': (distance is DistanceDto)
        ? (distance as DistanceDto).toJson()
        : {'text': distance.text, 'value': distance.value},
    'duration': (duration is DistanceDto)
        ? (duration as DistanceDto).toJson()
        : {'text': duration.text, 'value': duration.value},
    'status': status,
  };

  @override
  String toString() =>
      'GoogleDistanceMatrixEntity(distance: $distance, duration: $duration,'
      ' status: $status)';
}

class DistanceDto extends DistanceEntity {
  DistanceDto({required super.text, required super.value});

  factory DistanceDto.fromJson(Map<String, dynamic> json) {
    final text = json['text'] as String? ?? '';
    final valueNum = json['value'];
    final value = (valueNum is num) ? valueNum.toInt() : int.parse('$valueNum');
    return DistanceDto(text: text, value: value);
  }

  DistanceEntity toEntity() => DistanceEntity(text: text, value: value);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': text,
    'value': value,
  };

  @override
  String toString() => 'DistanceEntity(text: $text, value: $value)';
}
