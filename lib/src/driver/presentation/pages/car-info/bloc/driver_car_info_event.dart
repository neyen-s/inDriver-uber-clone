part of 'driver_car_info_bloc.dart';

sealed class DriverCarInfoEvent {}

final class BrandChanged extends DriverCarInfoEvent {
  BrandChanged(this.brand);
  final String brand;
}

final class ColorChanged extends DriverCarInfoEvent {
  ColorChanged(this.color);
  final String color;
}

final class PlateChanged extends DriverCarInfoEvent {
  PlateChanged(this.plate);
  final String plate;
}

final class SubmitCarChanges extends DriverCarInfoEvent {}

final class LoadDriverCarInfo extends DriverCarInfoEvent {
  LoadDriverCarInfo();
}
