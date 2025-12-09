import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/icon_row_info.dart';
import 'package:indriver_uber_clone/core/common/widgets/user_profile_img.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/bloc/client_map_trip_bloc.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/map-trip/widgets/blink_on_change.dart';

class ClientMapTripDetails extends StatefulWidget {
  const ClientMapTripDetails({required this.clientMapTripState, super.key});
  final ClientMapTripState clientMapTripState;

  @override
  State<ClientMapTripDetails> createState() => _ClientMapTripDetailsState();
}

class _ClientMapTripDetailsState extends State<ClientMapTripDetails> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final double _initialSize = 1;
  final double _minSize = 0.32;
  final double _maxSize = 1;

  Future<void> _toggleSheet() async {
    try {
      final cur = _sheetController.size;
      final mid = (_minSize + _maxSize) / 2;
      if (cur > mid) {
        await _sheetController.animateTo(
          _minSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        await _sheetController.animateTo(
          _maxSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.clientMapTripState.clientRequestResponse?.driver;
    final car = widget.clientMapTripState.clientRequestResponse?.carInfo;
    final media = MediaQuery.of(context);
    final maxHeight = min(media.size.height * 0.57, 320.h);

    final status = widget.clientMapTripState.clientRequestResponse?.status
        .toUpperCase();
    final secs = widget.clientMapTripState.estimatedTripDurationSeconds ?? 0;
    final watchValue = secs;

    String etaText() {
      final m = (secs ~/ 60).toString();
      final s = (secs % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    String arrivalText() {
      if (status == 'ARRIVED') {
        return 'Your driver has arrived';
      }
      if (secs <= 0) {
        return 'Your driver should arrive soon...';
      }
      return 'Will arrive in ${etaText()}';
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: maxHeight,
        width: double.infinity,
        child: DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _initialSize,
          minChildSize: _minSize,
          maxChildSize: _maxSize,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color.fromARGB(255, 186, 186, 186),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18).r,
                  topRight: const Radius.circular(18).r,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleSheet,
                      child: Center(
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          margin: EdgeInsets.only(top: 6.h, bottom: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),

                    Text(
                      'YOUR DRIVER',
                      style: TextStyle(
                        fontSize: 13.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      minVerticalPadding: 2,
                      title: Text(
                        '${driver?.name ?? ''}'
                        '${driver?.lastname ?? ''}',
                        style: TextStyle(fontSize: 12.h),
                      ),
                      subtitle: Text(
                        'Number: ${driver?.phone ?? ''}',
                        style: TextStyle(fontSize: 11.h),
                      ),
                      trailing: UserProfileImg(
                        imageUrl:
                            widget
                                .clientMapTripState
                                .clientRequestResponse
                                ?.driver
                                ?.image ??
                            '',
                      ),
                    ),
                    ListTile(
                      title: Text(
                        '${car?.brand ?? ''} ',
                        style: TextStyle(fontSize: 12.h),
                      ),
                      subtitle: Text(
                        '${car?.color ?? ''} - ${car?.plate ?? ''}',
                        style: TextStyle(fontSize: 11.h),
                      ),
                      trailing: Image.asset(
                        'assets/img/suv.png',
                        width: 50.w,
                        height: 50.w,
                      ),
                      minVerticalPadding: 0,
                      minTileHeight: 0,
                    ),
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: BlinkOnChange(
                        watch: watchValue,
                        // increase blink frequency: shorter duration
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          arrivalText(),
                          style: TextStyle(fontSize: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'TRIP INFO',
                      style: TextStyle(
                        fontSize: 15.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconRowInfo(
                      icon: Icons.location_on,
                      label: 'Pick up',
                      firstTittle:
                          widget
                              .clientMapTripState
                              .clientRequestResponse
                              ?.pickupDescription ??
                          '',
                    ),
                    IconRowInfo(
                      icon: Icons.flag,
                      label: 'Destination',
                      firstTittle:
                          widget
                              .clientMapTripState
                              .clientRequestResponse
                              ?.destinationDescription ??
                          '',
                    ),
                    SizedBox(height: 6.h),
                    IconRowInfo(
                      icon: Icons.euro,
                      label: 'Trip value',
                      firstTittle:
                          '${widget.clientMapTripState.clientRequestResponse?.fareOffered}€',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
