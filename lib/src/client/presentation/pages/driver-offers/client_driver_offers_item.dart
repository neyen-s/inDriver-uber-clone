import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_button.dart';
import 'package:indriver_uber_clone/core/common/widgets/user_profile_img.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/driver-offers/bloc/client_driver_offers_bloc.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';

class ClientDriverOffersItem extends StatelessWidget {
  const ClientDriverOffersItem({this.driverTripRequest, super.key});

  final DriverTripRequestEntity? driverTripRequest;

  @override
  Widget build(BuildContext context) {
    print('ClientDriverOffersItem ---> driverTripRequest: $driverTripRequest');
    return Container(
      margin: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(15).r),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 186, 186, 186),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: UserProfileImg(
              imageUrl: driverTripRequest?.driver?.image ?? '',
            ),
            title: Text(
              '${driverTripRequest?.driver?.name ?? ''}'
              ' ${driverTripRequest?.driver?.lastname ?? ''}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('"5.0 **"'), Text('"Mazda 3, blue **"')],
            ),
            trailing: Column(
              children: [
                Text(
                  '${driverTripRequest?.time.toStringAsFixed(2) ?? '--'} min',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${driverTripRequest?.distance.toStringAsFixed(2) ?? '--'} Km',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(left: 15.w),
                child: Text(
                  '${driverTripRequest?.fareOffered} €',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DefaultButton(
                text: Text(
                  'Accept',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                margin: EdgeInsets.only(right: 15.w, bottom: 12.h),
                color: Colors.blueAccent,
                onPressed: () {
                  context.read<ClientDriverOffersBloc>().add(
                    AsignDriver(
                      idClientRequest: driverTripRequest!.idClientRequest,
                      idDriver: driverTripRequest!.idDriver,
                      fareAssigned: driverTripRequest!.fareOffered,
                    ),
                  );
                },
                width: 120.w,
                height: 35.h,
              ), //TODO vcheck style and overflow
            ],
          ),
        ],
      ),
    );
  }
}
