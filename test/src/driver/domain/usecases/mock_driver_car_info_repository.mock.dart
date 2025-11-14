import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/repositories/driver_car_info_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDriverCarInfoRepository extends Mock
    implements DriverCarInfoRepository {}

// Fakes (para mocktail fallback values if necesary)
class FakeDriverCarInfoEntity extends Fake implements DriverCarInfoEntity {}
