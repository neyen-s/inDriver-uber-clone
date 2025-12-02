import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/dynamic_lottie_and_msg.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map-trip/bloc/driver_map_trip_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map-trip/driver_map_trip_content.dart';

class DriverMapTripPage extends StatefulWidget {
  const DriverMapTripPage({required this.idClientRequest, super.key});

  static const String routeName = 'driver/map-trip';

  final int idClientRequest;

  @override
  State<DriverMapTripPage> createState() => _DriverMapTripPageState();
}

class _DriverMapTripPageState extends State<DriverMapTripPage> {
  int? idClientRequest;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverMapTripBloc>().add(
        GetClientRequestById(widget.idClientRequest),
      );
    });
  }

  @override
  void dispose() {
    context.read<DriverMapTripBloc>().add(StopLocationTracking());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    idClientRequest = ModalRoute.of(context)?.settings.arguments as int?;
    return Scaffold(
      body: BlocConsumer<DriverMapTripBloc, DriverMapTripState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingService.show(context, message: 'Loading trip...');
          } else {
            LoadingService.hide(context);
          }
          if (state.errorMessage != null) {}
        },
        builder: (context, state) {
          if (state.errorMessage != null) {
            return Center(
              child: Column(
                children: [
                  DynamicLottieAndMsg(
                    message: 'Error: Something went wrong...',
                    onPressed: () {
                      context.read<DriverMapTripBloc>().add(
                        GetClientRequestById(widget.idClientRequest),
                      );
                    },
                    child: const Text(
                      'try again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }
          return const DriverMapTripContent();
        },
      ),
    );
  }
}
