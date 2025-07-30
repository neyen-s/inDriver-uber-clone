import 'package:flutter/material.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({
    required this.context,
    required this.originAddress,
    required this.destinationAddress,
    required this.distanceInKm,
    required this.duration,
    required this.price,
    required this.onConfirmPressed,
    required this.onCancelPressed,
    super.key,
  });
  final BuildContext context;
  final String originAddress;
  final String destinationAddress;
  final double distanceInKm;
  final Duration duration;
  final double price;
  final VoidCallback onConfirmPressed;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext contextt) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            IconButton(
              onPressed: onCancelPressed,
              icon: const Icon(Icons.close),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(Icons.location_on, 'Origen', originAddress),
                  const SizedBox(height: 8),
                  _buildRow(Icons.flag, 'Destino', destinationAddress),
                  const Divider(height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn(
                        'Distancia',
                        '${distanceInKm.toStringAsFixed(2)} km',
                      ),
                      _infoColumn('Duración', _formatDuration(duration)),
                      _infoColumn('Precio', '€${price.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onConfirmPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirmar viaje'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours h $remainingMinutes min';
    }
  }
}
