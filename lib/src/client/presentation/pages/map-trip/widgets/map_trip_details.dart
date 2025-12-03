// client_map_trip_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/icon_row_info.dart';
import 'package:indriver_uber_clone/core/common/widgets/user_profile_img.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class ClientMapTripDetails extends StatelessWidget {
  const ClientMapTripDetails({required this.clientRequest, super.key});
  final ClientRequestResponseEntity clientRequest;

  @override
  Widget build(BuildContext context) {
    final driver = clientRequest.driver;
    final car = clientRequest.carInfo;
    final fare = clientRequest.fareAssigned ?? clientRequest.fareOffered;

    return Container(
      padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
      height: 400.h,
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
          topRight: const Radius.circular(18).r,
          topLeft: const Radius.circular(18).r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR DRIVER',
            style: TextStyle(fontSize: 13.h, fontWeight: FontWeight.bold),
          ),
          ListTile(
            minVerticalPadding: 2,
            minTileHeight: 65,
            title: Text(
              '${driver?.name ?? ''}'
              '${driver?.lastname ?? ''}',
              style: TextStyle(fontSize: 12.h),
            ),
            subtitle: Text(
              'Number: ${driver?.phone ?? ''}',
              style: TextStyle(fontSize: 11.h),
            ),
            trailing: UserProfileImg(imageUrl: driver?.image ?? ''),
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
            child: Text(
              'Will arrive in '
              '${clientRequest.googleDistanceMatrix?.duration.text ?? '--'}'
              ' minutes',
              style: TextStyle(fontSize: 12.h),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'TRIP INFO',
            style: TextStyle(fontSize: 13.h, fontWeight: FontWeight.bold),
          ),
          IconRowInfo(
            icon: Icons.location_on,
            label: 'Pick up',
            firstTittle: clientRequest.pickupDescription,
          ),
          IconRowInfo(
            icon: Icons.flag,
            label: 'Destination',
            firstTittle: clientRequest.destinationDescription,
          ),
          SizedBox(height: 5.h),

          IconRowInfo(
            icon: Icons.euro,
            label: 'Trip value',
            firstTittle: '${clientRequest.fareOffered}€',
          ),
        ],
      ),
    );
  }
}
