import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/client_map_trip_content.dart';

class ClientMapTripPage extends StatefulWidget {
  const ClientMapTripPage({super.key});

  static const routeName = '/client-map-trip-page';

  @override
  State<ClientMapTripPage> createState() => _ClientMapTripPageState();
}

class _ClientMapTripPageState extends State<ClientMapTripPage> {
  //  final String idClientRequest;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ClientMapTripContent());
  }
}
