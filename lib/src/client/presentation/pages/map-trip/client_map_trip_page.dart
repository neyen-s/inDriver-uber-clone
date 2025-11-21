import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/bloc/client_map_trip_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/client_map_trip_content.dart';

class ClientMapTripPage extends StatefulWidget {
  const ClientMapTripPage({super.key});

  static const routeName = '/client-map-trip-page';

  @override
  State<ClientMapTripPage> createState() => _ClientMapTripPageState();
}

class _ClientMapTripPageState extends State<ClientMapTripPage> {
  int? idClientRequest = 2;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientMapTripBloc>().add(
        GetClientRequestById(idClientRequest!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientMapTripBloc, ClientMapTripState>(
        listener: (context, state) {
          /*           final responseClientRequest = state.clientRequestEntity;
          if (responseClientRequest != null) {
            print('Client Request fetched: ${responseClientRequest.id}');
          } */
        },
        builder: (context, state) {
          return ClientMapTripContent();
        },
      ),
    );
  }
}
