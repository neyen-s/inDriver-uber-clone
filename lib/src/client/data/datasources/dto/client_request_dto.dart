import 'package:indriver_uber_clone/src/client/domain/entities/client_request_entity.dart';

class ClientRequestDTO extends ClientRequestEntity {
  ClientRequestDTO({
    required super.id,
    required super.idClient,
    required super.fareOffered,
    required super.pickupDescription,
    required super.destinationDescription,
    required super.pickupLat,
    required super.pickupLng,
    required super.destinationLat,
    required super.destinationLng,
  });

  factory ClientRequestDTO.fromJson(Map<String, dynamic> map) {
    return ClientRequestDTO(
      id: map['id'] as int,
      idClient: map['id_client'] as int,
      fareOffered: map['fare_offered'] as double,
      pickupDescription: map['pickup_description'] as String,
      destinationDescription: map['destination_description'] as String,
      pickupLat: map['pickup_lat'] as double,
      pickupLng: map['pickup_lng'] as double,
      destinationLat: map['destination_lat'] as double,
      destinationLng: map['destination_lng'] as double,
    );
  }

  factory ClientRequestDTO.fromEntity(ClientRequestEntity entity) {
    return ClientRequestDTO(
      id: entity.id,
      idClient: entity.idClient,
      fareOffered: entity.fareOffered,
      pickupDescription: entity.pickupDescription,
      destinationDescription: entity.destinationDescription,
      pickupLat: entity.pickupLat,
      pickupLng: entity.pickupLng,
      destinationLat: entity.destinationLat,
      destinationLng: entity.destinationLng,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'id_client': idClient,
    'fare_offered': fareOffered,
    'pickup_description': pickupDescription,
    'destination_description': destinationDescription,
    'pickup_lat': pickupLat,
    'pickup_lng': pickupLng,
    'destination_lat': destinationLat,
    'destination_lng': destinationLng,
  };

  ClientRequestDTO toEntity() {
    return ClientRequestDTO(
      id: id,
      idClient: idClient,
      fareOffered: fareOffered,
      pickupDescription: pickupDescription,
      destinationDescription: destinationDescription,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
  }

  @override
  String toString() {
    return 'ClientRequestEntity(id: $id, idClient: $idClient, fareOffered:'
        ' $fareOffered, pickupDescription: $pickupDescription,'
        ' destinationDescription: $destinationDescription, pickupLat: '
        '$pickupLat, pickupLng: $pickupLng, destinationLat: $destinationLat, '
        ' destinationLng: $destinationLng)';
  }
}
