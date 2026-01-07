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
    required this.focusNode,
    required this.suffixIcon,
    required this.isSelected,
    this.onPredictionSelected,
    super.key,
  });

  final Widget? suffixIcon;
  final FocusNode focusNode;
  final TextEditingController controller;
  final String hintText;
  final bool isSelected;
  final void Function(LatLng) onPlaceSelected;

  final void Function(Prediction)? onPredictionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 3,
        ),
      ),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
        inputDecoration: InputDecoration(
          suffixIcon: suffixIcon,
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

          final lat = double.tryParse(prediction.lat ?? '');
          final lng = double.tryParse(prediction.lng ?? '');
          if (lat != null && lng != null) {
            onPlaceSelected(LatLng(lat, lng));
          }
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
        focusNode: focusNode,
      ),
    );
  }
}
