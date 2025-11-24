import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Widget build(BuildContext context) {
    idClientRequest = ModalRoute.of(context)?.settings.arguments as int?;
    return const Scaffold(body: DriverMapTripContent());
  }
}
