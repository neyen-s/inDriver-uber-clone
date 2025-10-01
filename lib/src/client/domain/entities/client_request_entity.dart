class ClientRequestEntity {
  ClientRequestEntity({
    required this.idClient,
    required this.fareOffered,
    required this.pickupDescription,
    required this.destinationDescription,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    this.id,
  });

  final int? id;
  final int idClient;
  final double fareOffered;
  final String pickupDescription;
  final String destinationDescription;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;

  ClientRequestEntity copyWith({
    int? id,
    int? idClient,
    double? fareOffered,
    String? pickupDescription,
    String? destinationDescription,
    double? pickupLat,
    double? pickupLng,
    double? destinationLat,
    double? destinationLng,
  }) {
    return ClientRequestEntity(
      id: id ?? this.id,
      idClient: idClient ?? this.idClient,
      fareOffered: fareOffered ?? this.fareOffered,
      pickupDescription: pickupDescription ?? this.pickupDescription,
      destinationDescription:
          destinationDescription ?? this.destinationDescription,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
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
