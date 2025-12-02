import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/icon_row_info.dart';
import 'package:indriver_uber_clone/core/common/widgets/user_profile_img.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

class DriverMapTripDetails extends StatelessWidget {
  const DriverMapTripDetails({required this.clientRequest, super.key});
  final ClientRequestResponseEntity clientRequest;

  @override
  Widget build(BuildContext context) {
    final pickup = clientRequest.pickupDescription;
    final dest = clientRequest.destinationDescription;
    final client = clientRequest.client;
    return Container(
      height: 350.h,
      padding: const EdgeInsets.all(12),
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
            'YOUR CLIENT',
            style: TextStyle(fontSize: 15.h, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text(
              '${client.name} '
              '${client.lastname}',
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
            style: TextStyle(fontSize: 15.h, fontWeight: FontWeight.bold),
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
          SizedBox(height: 6.h),

          IconRowInfo(
            icon: Icons.euro,
            label: 'Trip value',
            firstTittle: '${clientRequest.fareOffered}€',
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    /* llamar */
                  },
                  child: const Text('Llamar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    /* marcar llegada */
                  },
                  child: const Text('Llegué'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
