import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/bloc/client_driver_offers_bloc.dart';

class ClientDriverOffersPage extends StatefulWidget {
  const ClientDriverOffersPage({super.key});

  //final int idClientRequest;

  static const String routeName = 'client/driver-offers';

  @override
  State<ClientDriverOffersPage> createState() => _ClientDriverOffersPageState();
}

class _ClientDriverOffersPageState extends State<ClientDriverOffersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientDriverOffersBloc>().add(
        GetDriverTripOffersByClientReques(1), //TODO HARDCODED FOR NOW CHANGE
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientDriverOffersBloc, ClientDriverOffersState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingService.show(context);
          } else {
            LoadingService.hide(context);
          }
        },
        builder: (context, state) {
          final requestList = state.driverTripRequestEntity;

          if (!state.hasError) {
            if (requestList == null || requestList.isEmpty) {
              return const Center(child: Text('No requests available'));
            } else {
              return ListView.builder(
                itemCount: requestList.length,
                itemBuilder: (context, index) {
                  return Text('${requestList[index].id}');
                },
              );
            }
          } else {
            return const Center(
              child: Text('Error: Something went wrong, try again later'),
            );
          }
        },
      ),
    );
  }
}
