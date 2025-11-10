import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indriver_uber_clone/core/common/widgets/dynamic_lottie_and_msg.dart';
import 'package:indriver_uber_clone/core/services/loader_service.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/bloc/driver_client_requests_bloc.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/driver_client_requests_item.dart';

class DriverClientRequestsPage extends StatefulWidget {
  const DriverClientRequestsPage({super.key});

  @override
  State<DriverClientRequestsPage> createState() => _ClientRequestsPageState();
}

class _ClientRequestsPageState extends State<DriverClientRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverClientRequestsBloc>().add(
      const GetNearbyTripRequestEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AuthBackground(
        child: RefreshIndicator(
          //TODO MAYBE IS MORE CLIENT FRIENDLY TO PUT A BUTTON ON THE APPBAR IT WOULD HAVE TO BE ADDED ON THE DROVER MENU
          onRefresh: () async {
            context.read<DriverClientRequestsBloc>().add(
              const GetNearbyTripRequestEvent(),
            );
          },
          child:
              BlocConsumer<DriverClientRequestsBloc, DriverClientRequestsState>(
                listener: (context, state) {
                  if (state.isLoading) {
                    LoadingService.show(context);
                  } else {
                    LoadingService.hide(context);
                  }

                  if (state.driverTripRequest != null) {
                    CoreUtils.showSnackBar(
                      context,
                      'Your offer has been sent successfully',
                    );
                  }
                },
                builder: (context, state) {
                  final requestList = state.clientRequestResponseEntity;

                  if (!state.hasError) {
                    if (requestList == null || requestList.isEmpty) {
                      return const Center(
                        child: DynamicLottieAndMsg(
                          lottiePath: 'assets/lottie/map_search.json',
                          message: 'No requests available yet..',
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: requestList.length,
                        itemBuilder: (context, index) {
                          return DriverClientRequestsItem(
                            state: state,
                            clientRequestResponse: requestList[index],
                          );
                        },
                      );
                    }
                  } else {
                    final msg =
                        state.errorMessage ??
                        'Error: Something went wrong, try again later';
                    return DynamicLottieAndMsg(message: msg);
                  }
                },
              ),
        ),
      ),
    );
  }
}
