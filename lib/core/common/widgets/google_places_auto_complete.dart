import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class GooglePlaceAutocompleteField extends StatelessWidget {
  const GooglePlaceAutocompleteField({
    required this.controller,
    required this.hintText,
    required this.onPlaceSelected,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final void Function(LatLng) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: 'AIzaSyDU680a0zalIWFuVNDypJOXIQHlPZLZyPU',
        inputDecoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        boxDecoration: const BoxDecoration(color: Colors.white),
        debounceTime: 400,
        countries: const ['es'],
        getPlaceDetailWithLatLng: (Prediction prediction) {
          final lat = double.tryParse(prediction.lat ?? '');
          final lng = double.tryParse(prediction.lng ?? '');
          if (lat != null && lng != null) {
            onPlaceSelected(LatLng(lat, lng));
          }
        },
        itemClick: (Prediction prediction) {
          controller.text = prediction.description ?? '';
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
        seperatedBuilder: const Divider(),
        containerHorizontalPadding: 10,
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 7),
                Expanded(child: Text(prediction.description ?? '')),
              ],
            ),
          );
        },
      ),
    );
  }
}
