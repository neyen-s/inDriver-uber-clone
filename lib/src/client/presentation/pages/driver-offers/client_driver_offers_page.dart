import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/bloc/socket-bloc/bloc/socket_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/dynamic_lottie_and_msg.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/bloc/client_driver_offers_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/client_driver_offers_item.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/client_map_trip_page.dart';

class ClientDriverOffersPage extends StatefulWidget {
  const ClientDriverOffersPage({super.key});

  static const String routeName = 'client/driver-offers';

  @override
  State<ClientDriverOffersPage> createState() => _ClientDriverOffersPageState();
}

class _ClientDriverOffersPageState extends State<ClientDriverOffersPage> {
  int? _idClientRequest;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing client request id')),
        );
      });
      return;
    }

    final id = int.tryParse(arg.toString());
    if (id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid client request id')),
        );
      });
      return;
    }

    _idClientRequest = id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientDriverOffersBloc>().add(
        GetDriverTripOffersByClientRequest(id),
      );
      context.read<SocketBloc>().add(ListenClientRequestChannel(id.toString()));
    });
  }

  @override
  void dispose() {
    if (_idClientRequest != null) {
      context.read<SocketBloc>().add(
        StopListeningClientRequestChannel(_idClientRequest.toString()),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: BlocConsumer<ClientDriverOffersBloc, ClientDriverOffersState>(
          listener: (context, state) {
            if (state.isLoading) {
              LoadingService.show(context);
            } else {
              LoadingService.hide(context);
            }
            if (state.driverAssigned) {
              Navigator.pushNamed(
                context,
                ClientMapTripPage.routeName,
                arguments: state.idClientRequest,
              );
            }
          },
          builder: (context, state) {
            final requestList = state.driverTripRequestEntity;

            if (!state.hasError) {
              if (requestList == null || requestList.isEmpty) {
                return const Center(
                  child: DynamicLottieAndMsg(
                    lottiePath: 'assets/lottie/map_search.json',
                    message: 'No offers available yet..',
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: requestList.length,
                  itemBuilder: (context, index) {
                    return ClientDriverOffersItem(
                      driverTripRequest: requestList[index],
                    );
                  },
                );
              }
            } else {
              return const Center(
                child: DynamicLottieAndMsg(
                  message: 'Error: Something went wrong, try again later',
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
