class DriverCarInfoEntity {
  DriverCarInfoEntity({
    required this.brand,
    required this.color,
    required this.plate,
    this.idDriver,
  });
  final int? idDriver;
  final String brand;
  final String color;
  final String plate;

  DriverCarInfoEntity copyWith({
    int? idDriver,
    String? brand,
    String? color,
    String? plate,
  }) {
    return DriverCarInfoEntity(
      idDriver: idDriver ?? this.idDriver,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      plate: plate ?? this.plate,
    );
  }

  @override
  String toString() {
    return 'DriverCarInfoEntity(idDriver: $idDriver, brand: $brand,'
        ' color: $color, plate: $plate)';
  }
}
