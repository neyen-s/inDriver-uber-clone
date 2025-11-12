import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/bloc/driver_car_info_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/car-info/driver_car_info_content.dart';

class DriverCarInfoPage extends StatefulWidget {
  const DriverCarInfoPage({super.key});

  static const routeName = '/driver-car-info';

  @override
  State<DriverCarInfoPage> createState() => _DriverCarInfoPageState();
}

class _DriverCarInfoPageState extends State<DriverCarInfoPage> {
  UserEntity? user;

  @override
  void initState() {
    super.initState();
    context.read<DriverCarInfoBloc>().add(LoadDriverCarInfo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<DriverCarInfoBloc, DriverCarInfoState>(
        listenWhen: (previous, current) =>
            previous.carInfoUpdated == false &&
                current.carInfoUpdated == true ||
            previous.isLoading != current.isLoading ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          // loader
          if (state.isLoading) {
            LoadingService.show(
              context,
              message: 'Updating driver car info...',
            );
          } else {
            LoadingService.hide(context);
          }

          // success one-shot
          if (state.carInfoUpdated) {
            CoreUtils.showSnackBar(
              context,
              'Car information updated successfully!',
            );
          }

          // errors
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: const DriverCarInfoContent(),
      ),
    );
  }
}
