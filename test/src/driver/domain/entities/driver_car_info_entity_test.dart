import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

void main() {
  test('DriverCarInfoEntity copyWith returns updated copy', () {
    final e = DriverCarInfoEntity(
      idDriver: 1,
      brand: 'Mazda',
      color: 'Blue',
      plate: 'ABC123',
    );
    final updated = e.copyWith(brand: 'Toyota', plate: 'XYZ999');

    expect(updated.idDriver, e.idDriver);
    expect(updated.brand, 'Toyota');
    expect(updated.color, 'Blue');
    expect(updated.plate, 'XYZ999');
  });
}
