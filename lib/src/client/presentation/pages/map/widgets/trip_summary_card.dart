import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';
import 'package:indriver_uber_clone/core/extensions/text_input_formatters.dart';
import 'package:indriver_uber_clone/core/utils/validators.dart';

class TripSummaryCard extends StatefulWidget {
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
  final String duration;
  final double price;
  final void Function(String offeredPrice) onConfirmPressed;
  final VoidCallback onCancelPressed;

  @override
  State<TripSummaryCard> createState() => _TripSummaryCardState();
}

class _TripSummaryCardState extends State<TripSummaryCard> {
  TextEditingController offeredPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    offeredPriceController = TextEditingController(
      text: widget.price.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    offeredPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contextt) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(widget.context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(18).r,
          topLeft: const Radius.circular(18).r,
        ),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 186, 186, 186),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            IconButton(
              onPressed: widget.onCancelPressed,
              icon: const Icon(Icons.close),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(Icons.location_on, 'Origin', widget.originAddress),
                  const SizedBox(height: 8),
                  _buildRow(
                    Icons.flag,
                    'Destination',
                    widget.destinationAddress,
                  ),

                  const Divider(height: 24, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoColumn(
                        'Distance',
                        '${widget.distanceInKm.toStringAsFixed(2)} km',
                      ),
                      _infoColumn('Duration ', widget.duration),
                      _infoColumn(
                        'Avrg Price',
                        '${widget.price.toStringAsFixed(2)}€',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  DefaultTextField(
                    controller: offeredPriceController,
                    hintText: 'Offered price',
                    keyboardType: TextInputType.number,
                    fillColour: Colors.white,
                    filled: true,
                    focusNode: FocusNode(),
                    validator: validatePrice,
                    customInputFormatters: [DecimalTextInputFormatter()],
                    suffixIcon: const Icon(Icons.euro_symbol),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () =>
                        widget.onConfirmPressed(offeredPriceController.text),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color.fromARGB(255, 19, 58, 213),
                            Color.fromARGB(255, 65, 173, 255),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Container(
                        height: 38,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, color: Colors.white),
                            Text(
                              'Confirm trip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
      //crossAxisAlignment: CrossAxisAlignment.start,
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
