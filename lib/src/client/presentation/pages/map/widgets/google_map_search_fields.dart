import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indriver_uber_clone/core/common/widgets/google_places_auto_complete.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map/bloc/client_map_seeker_bloc.dart';

class GoogleMapSearchFields extends StatelessWidget {
  const GoogleMapSearchFields({
    required this.state,
    required this.originFocusNode,
    required this.destinationFocusNode,
    required this.controller,
    required this.pickUpController,
    required this.destinationController,
    required this.onMoveBySearchChanged,
    required this.onOriginSelected,
    required this.isOriginSelected,
    required this.isDestinationSelected,
    required this.onDestinationSelected,
    super.key,
  });

  final ClientMapSeekerState state;
  final FocusNode originFocusNode;
  final FocusNode destinationFocusNode;
  final TextEditingController pickUpController;
  final TextEditingController destinationController;
  final Completer<GoogleMapController> controller;
  final bool isOriginSelected;
  final bool isDestinationSelected;
  final ValueChanged<bool> onMoveBySearchChanged;
  final ValueChanged<LatLng> onOriginSelected;
  final ValueChanged<LatLng> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        color: Colors.grey[200]!.withValues(alpha: 0.8),
      ),
      key: const ValueKey('search_fields'),
      height: 120.h,
      margin: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GooglePlaceAutocompleteField(
            controller: pickUpController,
            hintText: 'Pick up address',
            focusNode: originFocusNode,
            isSelected: isOriginSelected,
            onPlaceSelected: (latLng) {
              onMoveBySearchChanged(true);
              onOriginSelected(latLng);
            },
            suffixIcon: state is FetchingTextAdress && originFocusNode.hasFocus
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
            isSelected: isDestinationSelected,
            focusNode: destinationFocusNode,
            onPlaceSelected: onDestinationSelected,
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
    );
  }
}
