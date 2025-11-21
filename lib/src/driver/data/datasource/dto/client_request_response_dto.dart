import 'dart:convert';
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
  });

  factory ClientRequestResponseDto.fromJson(Map<String, dynamic> json) {
    // helpers to safely parse numeric fields
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s);
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString();
      return int.tryParse(s);
    }

    // required fields (throw early if absolutely missing)
    final id = _toInt(json['id']);
    final idClient = _toInt(json['id_client']);
    final fareOffered = _toDouble(json['fare_offered']);

    if (id == null || idClient == null || fareOffered == null) {
      throw Exception(
        'ClientRequestResponseDto.fromJson: missing required fields id/id_client/fare_offered',
      );
    }

    // parse updated_at (be defensive)
    DateTime updatedAt;
    final rawUpdated = json['updated_at'];
    if (rawUpdated is String) {
      updatedAt = DateTime.parse(rawUpdated);
    } else if (rawUpdated is DateTime) {
      updatedAt = rawUpdated;
    } else {
      // fallback to now or throw depending how strict you want to be
      updatedAt = DateTime.now();
    }

    // positions
    PositionDto parsePos(dynamic posRaw) {
      if (posRaw is Map<String, dynamic>) {
        return PositionDto.fromJson(posRaw);
      }
      throw Exception('pickup/destination position invalid: $posRaw');
    }

    // client (required)
    final clientMap = json['client'] as Map<String, dynamic>?;
    final client = clientMap != null
        ? ClientDto.fromJson(clientMap)
        : ClientDto(name: '', image: '', phone: '', lastname: '');

    // optional fields
    final distance = _toDouble(json['distance']);
    final timeDifference = _toInt(json['time_difference']);

    final driverMap = json['driver'] as Map<String, dynamic>?;
    final driver = driverMap != null ? ClientDto.fromJson(driverMap) : null;

    GoogleDistanceMatrixDto? googleDistance;
    final gdmRaw = json['google_distance_matrix'];
    if (gdmRaw is Map<String, dynamic>) {
      try {
        // Google API element sometimes provides distance/duration with text & value
        googleDistance = GoogleDistanceMatrixDto.fromJson(gdmRaw);
      } catch (_) {
        // try to adapt common element structures (like a single element from matrix)
        // if gdmRaw already matches expected shape this will succeed above
        googleDistance = null;
      }
    }

    final fareAssigned = _toDouble(json['fare_assigned']);
    final idDriver = _toInt(json['id_driver']);

    return ClientRequestResponseDto(
      id: id,
      idClient: idClient,
      fareOffered: fareOffered,
      pickupDescription: (json['pickup_description'] as String?) ?? '',
      destinationDescription:
          (json['destination_description'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      updatedAt: updatedAt,
      pickupPosition: parsePos(json['pickup_position'] as Map<String, dynamic>),
      destinationPosition: parsePos(
        json['destination_position'] as Map<String, dynamic>,
      ),
      client: client,
      timeDifference: timeDifference,
      distance: distance,
      driver: driver,
      googleDistanceMatrix: googleDistance,
      idDriver: idDriver,
      fareAssigned: fareAssigned,
    );
  }
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
    );
  }
  static List<ClientRequestResponseDto> listFromJson(List<dynamic> json) => json
      .map((e) => ClientRequestResponseDto.fromJson(e as Map<String, dynamic>))
      .toList();
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
  };
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
  PositionDto({required super.x, required super.y});

  factory PositionDto.fromJson(Map<String, dynamic> json) {
    final xNum = json['x'] ?? json['lat'] ?? json['latitude'];
    final yNum = json['y'] ?? json['lng'] ?? json['longitude'];

    return PositionDto(
      x: (xNum is num) ? xNum.toDouble() : double.parse('$xNum'),
      y: (yNum is num) ? yNum.toDouble() : double.parse('$yNum'),
    );
  }
  PositionEntity toEntity() {
    return PositionEntity(x: x, y: y);
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  String toString() => 'PositionEntity(x: $x, y: $y)';
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
