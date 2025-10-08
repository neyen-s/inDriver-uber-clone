class ClientRequestResponseEntity {
  ClientRequestResponseEntity({
    required this.id,
    required this.idClient,
    required this.fareOffered,
    required this.pickupDescription,
    required this.destinationDescription,
    required this.status,
    required this.updatedAt,
    required this.pickupPosition,
    required this.destinationPosition,
    required this.distance,
    required this.timeDifference,
    required this.client,
    required this.googleDistanceMatrix,
  });
  final int id;
  final int idClient;
  final double fareOffered;
  final String pickupDescription;
  final String destinationDescription;
  final String status;
  final DateTime updatedAt;
  final PositionEntity pickupPosition;
  final PositionEntity destinationPosition;
  final double distance;
  final int timeDifference;
  final ClientEntity client;
  final GoogleDistanceMatrixEntity googleDistanceMatrix;

  ClientRequestResponseEntity copyWith({
    int? id,
    int? idClient,
    double? fareOffered,
    String? pickupDescription,
    String? destinationDescription,
    String? status,
    DateTime? updatedAt,
    PositionEntity? pickupPosition,
    PositionEntity? destinationPosition,
    double? distance,
    int? timeDifference,
    ClientEntity? client,
    GoogleDistanceMatrixEntity? googleDistanceMatrix,
  }) {
    return ClientRequestResponseEntity(
      id: id ?? this.id,
      idClient: idClient ?? this.idClient,
      fareOffered: fareOffered ?? this.fareOffered,
      pickupDescription: pickupDescription ?? this.pickupDescription,
      destinationDescription:
          destinationDescription ?? this.destinationDescription,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      pickupPosition: pickupPosition ?? this.pickupPosition,
      destinationPosition: destinationPosition ?? this.destinationPosition,
      distance: distance ?? this.distance,
      timeDifference: timeDifference ?? this.timeDifference,
      client: client ?? this.client,
      googleDistanceMatrix: googleDistanceMatrix ?? this.googleDistanceMatrix,
    );
  }

  @override
  String toString() {
    return 'ClientRequestResponseEntity(id: $id, idClient: $idClient,'
        ' fareOffered: $fareOffered, pickupDescription: $pickupDescription, '
        'destinationDescription: $destinationDescription, status: $status, '
        'updatedAt: $updatedAt, pickupPosition: $pickupPosition, '
        'destinationPosition: $destinationPosition, distance: $distance, '
        'timeDifference: $timeDifference, client: $client,'
        ' googleDistanceMatrix: $googleDistanceMatrix)';
  }
}

class ClientEntity {
  ClientEntity({
    required this.name,
    required this.image,
    required this.phone,
    required this.lastname,
  });

  final String name;
  final String image;
  final String phone;
  final String lastname;
  ClientEntity copyWith({
    String? name,
    String? image,
    String? phone,
    String? lastname,
  }) {
    return ClientEntity(
      name: name ?? this.name,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      lastname: lastname ?? this.lastname,
    );
  }

  @override
  String toString() {
    return 'ClientEntity(name: $name, image: $image, phone: $phone,'
        ' lastname: $lastname)';
  }
}

class PositionEntity {
  PositionEntity({required this.x, required this.y});

  final double x;
  final double y;
  PositionEntity copyWith({double? x, double? y}) {
    return PositionEntity(x: x ?? this.x, y: y ?? this.y);
  }

  @override
  String toString() => 'PositionEntity(x: $x, y: $y)';
}

class GoogleDistanceMatrixEntity {
  GoogleDistanceMatrixEntity({
    required this.distance,
    required this.duration,
    required this.status,
  });
  final DistanceEntity distance;
  final DistanceEntity duration;
  final String status;
  GoogleDistanceMatrixEntity copyWith({
    DistanceEntity? distance,
    DistanceEntity? duration,
    String? status,
  }) {
    return GoogleDistanceMatrixEntity(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'GoogleDistanceMatrixEntity(distance: $distance, duration: $duration,'
      ' status: $status)';
}

class DistanceEntity {
  DistanceEntity({required this.text, required this.value});
  final String text;
  final int value;

  DistanceEntity copyWith({String? text, int? value}) {
    return DistanceEntity(text: text ?? this.text, value: value ?? this.value);
  }

  @override
  String toString() => 'DistanceEntity(text: $text, value: $value)';
}
