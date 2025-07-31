import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

class ConfirmRouteBtn extends StatefulWidget {
  ConfirmRouteBtn({
    required this.cameraTarget,
    required this.pickUpController,
    required this.destinationController,
    required this.originLatLng,
    required this.destinationLatLng,
    super.key,
  });
  final TextEditingController pickUpController;
  final TextEditingController destinationController;
  LatLng? cameraTarget;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;

  @override
  State<ConfirmRouteBtn> createState() => _ConfirmRouteBtnState();
}

class _ConfirmRouteBtnState extends State<ConfirmRouteBtn> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30.h,
      left: 20.w,
      right: 20.w,
      child: ElevatedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 300));
          final origin = widget.pickUpController.text.trim();
          final destination = widget.destinationController.text.trim();

          if (origin.isNotEmpty &&
              destination.isNotEmpty &&
              widget.originLatLng != null &&
              widget.destinationLatLng != null) {
            setState(() {
              widget.cameraTarget = null;
            });
            context.read<ClientMapSeekerBloc>().add(
              ConfirmTripDataEntered(
                destinationLatLng: widget.destinationLatLng!,
                originLatLng: widget.originLatLng!,
                origin: origin,
                destination: destination,
              ),
            );
          }
        },
        child: const Text('Confirm destination'),
      ),
    );
  }
}
