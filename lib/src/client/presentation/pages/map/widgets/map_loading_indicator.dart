import 'package:flutter/material.dart';

class MapLoadingIndicator extends StatelessWidget {
  const MapLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
