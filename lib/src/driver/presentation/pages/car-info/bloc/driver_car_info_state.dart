part of 'driver_car_info_bloc.dart';

class DriverCarInfoState extends Equatable {
  const DriverCarInfoState({
    this.brand = const BrandInput.pure(),
    this.color = const ColorInput.pure(),
    this.plate = const PlateInput.pure(),
    this.isLoading = false,
    this.errorMessage,
    this.idDriver,
    this.hasSubmitted = false,
    this.carInfoUpdated = false,
  });

  final BrandInput brand;
  final ColorInput color;
  final PlateInput plate;
  final bool isLoading;
  final String? errorMessage;
  final int? idDriver;
  final bool hasSubmitted;
  final bool carInfoUpdated;

  bool get isValid => Formz.validate([brand, color, plate]);

  DriverCarInfoState copyWith({
    BrandInput? brand,
    ColorInput? color,
    PlateInput? plate,
    bool? isLoading,
    bool? carInfoUpdated,
    String? errorMessage,
    int? idDriver,
    bool? hasSubmitted,
  }) {
    return DriverCarInfoState(
      brand: brand ?? this.brand,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      idDriver: idDriver ?? this.idDriver,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      carInfoUpdated: carInfoUpdated ?? this.carInfoUpdated,
    );
  }

  @override
  List<Object?> get props => [
    brand,
    color,
    plate,
    isLoading,
    errorMessage,
    idDriver,
    hasSubmitted,
    carInfoUpdated,
  ];
}
