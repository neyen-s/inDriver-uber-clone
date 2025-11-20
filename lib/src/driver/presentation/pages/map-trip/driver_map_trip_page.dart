import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/map-trip/driver_map_trip_content.dart';

class DriverMapTripPage extends StatelessWidget {
  const DriverMapTripPage({super.key});

  static const String routeName = 'driver/map-trip';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: DriverMapTripContent());
  }
}
