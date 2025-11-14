import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:indriver_uber_clone/core/utils/fold_or_emit_error.dart';
import 'package:indriver_uber_clone/src/auth/domain/usecase/auth_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_car_info_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/create_driver_car_info_use_case.dart';
import 'package:indriver_uber_clone/src/driver/domain/usecases/driver-car-info/driver_car_info_use_cases.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/car_inputs.dart';

part 'driver_car_info_event.dart';
part 'driver_car_info_state.dart';

class DriverCarInfoBloc extends Bloc<DriverCarInfoEvent, DriverCarInfoState> {
  DriverCarInfoBloc(this.authUseCases, this.driverCarInfoUseCases)
    : super(const DriverCarInfoState()) {
    on<BrandChanged>(_onBrandChanged);
    on<ColorChanged>(_onColorChanged);
    on<PlateChanged>(_onPlateChanged);
    on<SubmitCarChanges>(_onSubmitCarChanges);
    on<LoadDriverCarInfo>(_onLoadDriverCarInfo);
  }

  final AuthUseCases authUseCases;
  final DriverCarInfoUseCases driverCarInfoUseCases;

  void _onBrandChanged(BrandChanged event, Emitter<DriverCarInfoState> emit) {
    final brand = BrandInput.dirty(event.brand);
    emit(state.copyWith(brand: brand));
  }

  void _onColorChanged(ColorChanged event, Emitter<DriverCarInfoState> emit) {
    final color = ColorInput.dirty(event.color);
    emit(state.copyWith(color: color));
  }

  void _onPlateChanged(PlateChanged event, Emitter<DriverCarInfoState> emit) {
    final plate = PlateInput.dirty(event.plate);
    emit(state.copyWith(plate: plate));
  }

  Future<void> _onSubmitCarChanges(
    SubmitCarChanges event,
    Emitter<DriverCarInfoState> emit,
  ) async {
    final brand = BrandInput.dirty(state.brand.value);
    final color = ColorInput.dirty(state.color.value);
    final plate = PlateInput.dirty(state.plate.value);
    emit(state.copyWith(hasSubmitted: true));
    final isValid = Formz.validate([brand, color, plate]);
    if (!isValid) {
      emit(state.copyWith(brand: brand, color: color, plate: plate));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final carInfo = DriverCarInfoEntity(
        idDriver: state.idDriver,
        brand: brand.value,
        color: color.value,
        plate: plate.value,
      );
      final result = await driverCarInfoUseCases.createDriverCarInfoUseCase(
        CreateDriverCarInfoParams(driverCarInfoEntity: carInfo),
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoading: false, errorMessage: failure.toString()),
          );
        },
        (_) {
          emit(
            state.copyWith(
              isLoading: false,
              brand: BrandInput.dirty(carInfo.brand),
              color: ColorInput.dirty(carInfo.color),
              plate: PlateInput.dirty(carInfo.plate),
              carInfoUpdated: true,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadDriverCarInfo(
    LoadDriverCarInfo event,
    Emitter<DriverCarInfoState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      int driverId;
      if (state.idDriver != null) {
        driverId = state.idDriver!;
      } else {
        final authEither = await authUseCases.getUserSessionUseCase();
        final auth = await foldOrEmitError(
          authEither,
          emit,
          (msg) => state.copyWith(isLoading: false, errorMessage: msg),
        );
        if (auth == null) return;
        driverId = auth.user.id;
        emit(state.copyWith(idDriver: driverId));
      }
      final carInfo = await driverCarInfoUseCases.getDriverCarInfoUseCase(
        state.idDriver!,
      );
      carInfo.fold(
        (failure) {
          emit(
            state.copyWith(isLoading: false, errorMessage: failure.toString()),
          );
        },
        (carInfo) {
          emit(
            state.copyWith(
              brand: BrandInput.dirty(carInfo.brand),
              color: ColorInput.dirty(carInfo.color),
              plate: PlateInput.dirty(carInfo.plate),
              isLoading: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
