import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/dynamic_lottie_and_msg.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/bloc/client_map_trip_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/client_map_trip_content.dart';

class ClientMapTripPage extends StatefulWidget {
  const ClientMapTripPage({required this.idClientRequest, super.key});

  static const routeName = '/client-map-trip-page';

  final int idClientRequest;

  @override
  State<ClientMapTripPage> createState() => _ClientMapTripPageState();
}

class _ClientMapTripPageState extends State<ClientMapTripPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientMapTripBloc>().add(
        GetClientRequestById(widget.idClientRequest),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: BlocConsumer<ClientMapTripBloc, ClientMapTripState>(
          listener: (context, state) {
            if (state.isLoading) {
              LoadingService.show(context);
            } else {
              LoadingService.hide(context);
            }
          },
          builder: (context, state) {
            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  children: [
                    DynamicLottieAndMsg(
                      message: 'Error: Something went wrong...',
                      onPressed: () {
                        context.read<ClientMapTripBloc>().add(
                          GetClientRequestById(widget.idClientRequest),
                        );
                      },
                      child: const Text(
                        'try again',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(), //TODO CHECK THE POP problem
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              );
            }

            return const ClientMapTripContent();
          },
        ),
      ),
    );
  }
}
