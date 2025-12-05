import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/icon_row_info.dart';
import 'package:indriver_uber_clone/core/common/widgets/user_profile_img.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class DriverMapTripDetails extends StatefulWidget {
  const DriverMapTripDetails({required this.clientRequest, super.key});
  final ClientRequestResponseEntity clientRequest;

  @override
  State<DriverMapTripDetails> createState() => _DriverMapTripDetailsState();
}

class _DriverMapTripDetailsState extends State<DriverMapTripDetails> {
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
    final pickup = widget.clientRequest.pickupDescription;
    final dest = widget.clientRequest.destinationDescription;
    final client = widget.clientRequest.client;

    final media = MediaQuery.of(context);
    final maxHeight = min(media.size.height * 0.57, 320.h);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: maxHeight,
        width: double.infinity,
        child: DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _initialSize,
          minChildSize: _minSize,
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
                      'YOUR CLIENT',
                      style: TextStyle(
                        fontSize: 15.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ListTile(
                      title: Text(
                        '${client.name} ${client.lastname}',
                        style: TextStyle(fontSize: 12.h),
                      ),
                      subtitle: Text(
                        'Number: ${client.phone}',
                        style: TextStyle(fontSize: 11.h),
                      ),
                      trailing: UserProfileImg(imageUrl: client.image),
                    ),

                    const SizedBox(height: 6),

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
                      firstTittle: pickup,
                    ),

                    IconRowInfo(
                      icon: Icons.flag,
                      label: 'Destination',
                      firstTittle: dest,
                    ),

                    SizedBox(height: 6.h),

                    IconRowInfo(
                      icon: Icons.euro,
                      label: 'Trip value',
                      firstTittle: '${widget.clientRequest.fareOffered}€',
                    ),

                    const SizedBox(height: 12),

                    // actions row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: implement call action
                            },
                            child: const Text('Call'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: implement "Arrived" action
                            },
                            child: const Text('Arrived'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
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
