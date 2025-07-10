import 'package:dartz/dartz.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:indriver_uber_clone/core/errors/faliures.dart';
import 'package:indriver_uber_clone/core/utils/typedefs.dart';
import 'package:indriver_uber_clone/src/client/domain/repository/geolocator_repository.dart';

class GeolocatorRepositoryImpl implements GeolocatorRepository {
  @override
  ResultFuture<Position> findPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
          ServerFailure(
            message: 'Location services are disabled.',
            statusCode: 403,
          ),
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            ServerFailure(
              message: 'Location permissions denied.',
              statusCode: 403,
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          ServerFailure(
            message: 'Permisions are permanently denied.',
            statusCode: 403,
          ),
        );
      }

      final position = await Geolocator.getCurrentPosition();
      return Right(position);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 404));
    }
  }

  @override
  ResultFuture<BitmapDescriptor> createMarkerFromAsset(String path) async {
    try {
      final configuration = ImageConfiguration(size: Size(35.w, 35.h));
      final BitmapDescriptor descriptor = await BitmapDescriptor.asset(
        configuration,
        path,
      );
      return Right(descriptor);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 400));
    }
  }

  @override
  ResultFuture<Marker> getMarker(
    String id,
    String title,
    String content,
    LatLng position,
    BitmapDescriptor icon,
  ) async {
    try {
      final markerId = MarkerId(id);
      final marker = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(title: title, snippet: content),
        icon: icon,
      );
      return Right(marker);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 400));
    }
  }
}
