class DriverPositionEntity {
  DriverPositionEntity({
    required this.idDriver,
    required this.lat,
    required this.lng,
  });

  const DriverPositionEntity.empty() : idDriver = 0, lat = 0.0, lng = 0.0;

  final int idDriver;
  final double lat;
  final double lng;

  DriverPositionEntity copyWith({int? idDriver, double? lat, double? lng}) {
    return DriverPositionEntity(
      idDriver: idDriver ?? this.idDriver,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  String toString() =>
      'DriverPositionEntity(idDriver: $idDriver, lat: $lat, lng: $lng)';
}
