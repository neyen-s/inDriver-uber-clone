import 'package:flutter_test/flutter_test.dart';
import 'package:indriver_uber_clone/src/driver/data/datasource/dto/driver_car_info_dto.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';

void main() {
  group('DriverCarInfoDTO', () {
    test('DriverCarInfoDTO fromJson parses id_driver and fields', () {
      final json = {
        'id_driver': 1,
        'brand': 'Toyota',
        'color': 'Red',
        'plate': '0768 OWJ',
      };

      final dto = DriverCarInfoDTO.fromJson(json);

      expect(dto.idDriver, 1);
      expect(dto.brand, 'Toyota');
      expect(dto.color, 'Red');
      expect(dto.plate, '0768 OWJ');
    });

    test('fromJson throws when required field brand is missing', () {
      final json = {
        'id_driver': 1,
        // 'brand' omitted on purpose
        'color': 'Red',
        'plate': '0768 OWJ',
      };

      // fromJson uses `json['brand'] as String` so it will throw (TypeError / NoSuchMethod)
      expect(() => DriverCarInfoDTO.fromJson(json), throwsA(isA<Error>()));
    });
    test('fromJson throws error when idDriver field is wrong', () {
      final json = {
        'iddriver': 1, // este test falla
        'brand': 'Toyota',
        'color': 'Red',
        'plate': '0768 OWJ',
      };
      final dto = DriverCarInfoDTO.fromJson(json);
      expect(dto.idDriver, null);
      expect(dto.brand, 'Toyota');
      expect(dto.color, 'Red');
      expect(dto.plate, '0768 OWJ');
    });

    test('DriverCarInfoDTO tojson includes id_driver when not null', () {
      final dto = DriverCarInfoDTO(
        idDriver: 2,
        brand: 'Mazda',
        color: 'Black',
        plate: '0768 OWJ',
      );

      final json = dto.toJson();

      expect(json['id_driver'], 2);
      expect(json['brand'], 'Mazda');
      expect(json['color'], 'Black');
      expect(json['plate'], '0768 OWJ');
    });

    test('DriverCarInfoDTO from entity returns a DriverCarInfoDTO', () {
      final entity = DriverCarInfoEntity(
        idDriver: 3,
        brand: 'Honda',
        color: 'White',
        plate: '1234 ABC',
      );

      final dto = DriverCarInfoDTO.fromEntity(entity);
      expect(dto.idDriver, entity.idDriver);
      expect(dto.brand, entity.brand);
      expect(dto.color, entity.color);
      expect(dto.plate, entity.plate);
    });
  });
}
