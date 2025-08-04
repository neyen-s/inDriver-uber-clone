import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/common/widgets/google_places_auto_complete.dart';
import 'package:indriver_uber_clone/core/utils/map-utils/move_map_camera.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

class GoogleMapSearchFields extends StatelessWidget {
  GoogleMapSearchFields({
    required this.state,
    required this.originFocusNode,
    required this.destinationFocusNode,
    required this.controller,
    required this.pickUpController,
    required this.destinationController,
    required this.moveBySearch,
    super.key,
  });
  final ClientMapSeekerState state;
  final FocusNode originFocusNode;
  final FocusNode destinationFocusNode;
  final TextEditingController pickUpController;
  final TextEditingController destinationController;
  final Completer<GoogleMapController> controller;
  late LatLng originLatLng;
  late LatLng destinationLatLng;
  late bool moveBySearch = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('search_fields'),
      height: 120.h,
      margin: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      alignment: Alignment.center,
      child: Card(
        surfaceTintColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GooglePlaceAutocompleteField(
              controller: pickUpController,
              hintText: 'Pick up address',
              focusNode: originFocusNode,
              onPlaceSelected: (latLng) {
                moveBySearch = true;
                moveCameraTo(controller: controller, target: latLng, zoom: 16);
                originLatLng = latLng;
              },
              suffixIcon:
                  state is FetchingTextAdress && originFocusNode.hasFocus
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 5.h),
            GooglePlaceAutocompleteField(
              controller: destinationController,
              hintText: 'Destination address',
              focusNode: destinationFocusNode,
              onPlaceSelected: (latLng) {
                moveCameraTo(controller: controller, target: latLng, zoom: 16);
                destinationLatLng = latLng;
              },
              suffixIcon:
                  state is FetchingTextAdress && destinationFocusNode.hasFocus
                  ? Padding(
                      padding: EdgeInsets.all(12.r),
                      child: SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
