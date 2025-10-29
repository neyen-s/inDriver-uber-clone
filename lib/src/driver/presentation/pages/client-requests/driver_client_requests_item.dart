import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_button.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/driver_trip_request_entity.dart';
import 'package:indriver_uber_clone/src/driver/presentation/pages/client-requests/bloc/driver_client_requests_bloc.dart';

class DriverClientRequestsItem extends StatelessWidget {
  const DriverClientRequestsItem({
    required this.state,
    this.clientRequestResponse,
    super.key,
  });

  final DriverClientRequestsState state;
  final ClientRequestResponseEntity? clientRequestResponse;
  static const double _labelWidth = 90;

  @override
  Widget build(BuildContext context) {
    // Estilos reutilizables
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 16.sp,
    );
    final subtitleBold = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 14.sp,
    );
    final fieldLabel = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 15.sp,
    );
    final fieldValue = TextStyle(fontSize: 14.sp);

    final client = clientRequestResponse?.client;
    final google = clientRequestResponse?.googleDistanceMatrix;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(18).r),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 191, 200, 212),
            Color.fromARGB(255, 186, 186, 186),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            // Header (avatar + name + fare)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Fair offered:', style: titleStyle),
                          Text(
                            ' ${clientRequestResponse?.fareOffered.toStringAsFixed(2) ?? '--'}€',
                            style: titleStyle.copyWith(
                              color: const Color.fromARGB(255, 21, 114, 24),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                      Text(
                        '${client?.name ?? ''} ${client?.lastname ?? ''}'
                            .trim(),
                        style: subtitleBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _avatar(client?.image),
              ],
            ),

            const SizedBox(height: 8),

            // Trip info
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
                  SizedBox(width: 4.w),

                  Text('Trip info:', style: subtitleBold),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            _infoRow(
              label: 'Pick up:',
              value: clientRequestResponse?.pickupDescription ?? '',
              labelWidth: _labelWidth,
              labelStyle: fieldLabel,
              valueStyle: fieldValue,
            ),
            SizedBox(height: 6.h),
            _infoRow(
              label: 'Destination:',
              value: clientRequestResponse?.destinationDescription ?? '',
              labelWidth: _labelWidth,
              labelStyle: fieldLabel,
              valueStyle: fieldValue,
            ),

            Divider(height: 18.h, thickness: 0),

            // Time & Distance + button
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.taxi_alert, size: 20, color: Colors.grey[700]),
                  SizedBox(width: 4.w),
                  Text('Time & Distance:', style: fieldLabel),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),
                      _infoRow(
                        label: 'Duration:',
                        value: google?.duration.text ?? '',
                        labelWidth: _labelWidth,
                        labelStyle: fieldLabel,
                        valueStyle: fieldValue,
                      ),
                      SizedBox(height: 6.h),
                      _infoRow(
                        label: 'Distance:',
                        value: google?.distance.text ?? '',
                        labelWidth: _labelWidth,
                        labelStyle: fieldLabel,
                        valueStyle: fieldValue,
                      ),
                    ],
                  ),
                ),

                // SizedBox(width: 8.w),
                DefaultButton(
                  width: 130.w,
                  margin: EdgeInsets.only(right: 4.w),
                  text: Text(
                    'Counteroffer',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: () async {
                    await _onCounterofferPressed(
                      context,
                      clientRequestResponse,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required double labelWidth,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth.w,
          child: Text(label, style: labelStyle),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: valueStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _avatar(String? imageUrl) {
    final trimmed = imageUrl?.trim() ?? '';
    final uri = trimmed.isNotEmpty ? Uri.tryParse(trimmed) : null;
    final isValidNetworkImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);

    return SizedBox(
      width: 55.w,
      height: 55.w,
      child: ClipOval(
        child: isValidNetworkImage
            ? Image.network(
                trimmed,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/img/user.png', fit: BoxFit.cover),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CupertinoActivityIndicator());
                },
              )
            : Image.asset('assets/img/user.png', fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _onCounterofferPressed(
    BuildContext context,
    ClientRequestResponseEntity? clientRequestResponse,
  ) async {
    final controller = TextEditingController(
      text: clientRequestResponse?.fareOffered.toString(),
    );
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Trip Counteroffer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Enter your fare',
                prefixIcon: Icon(Icons.euro),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send fare'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      final fare = double.tryParse(controller.text) ?? 0.0;
      debugPrint('Counteroffer sent with fare: $fare');
      debugPrint(
        'clientRequestResponse.googleDistanceMatrix.duration.value ${clientRequestResponse?.googleDistanceMatrix.duration.value}',
      );

      if (clientRequestResponse != null && state.idDriver != null) {
        context.read<DriverClientRequestsBloc>().add(
          CreateDriverTripRequestEvent(
            driverTripRequestEntity: DriverTripRequestEntity(
              idClientRequest: clientRequestResponse.id,
              idDriver: state.idDriver ?? 0,
              fareOffered: fare,
              time:
                  clientRequestResponse.googleDistanceMatrix.duration.value
                      .toDouble() /
                  60,

              distance:
                  clientRequestResponse.googleDistanceMatrix.distance.value
                      .toDouble() /
                  1000,
            ),
          ),
        );
      } else {
        debugPrint(
          'Error sending COUNTEROFFER: clientRequestResponse or'
          ' idDriver is null',
        );
        CoreUtils.showSnackBar(
          context,
          'Error: Unable to send counteroffer, try again later',
        );
      }
    }
  }
}
