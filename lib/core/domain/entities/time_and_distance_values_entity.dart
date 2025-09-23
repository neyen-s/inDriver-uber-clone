class TimeAndDistanceValuesEntity {
  TimeAndDistanceValuesEntity({
    required this.recommendedValue,
    required this.destinationAddresses,
    required this.originAddresses,
    required this.distance,
    required this.duration,
  });
  final double recommendedValue;
  final String destinationAddresses;
  final String originAddresses;
  final DistanceEntity distance;
  final DurationEntity duration;

  TimeAndDistanceValuesEntity copyWith({
    double? recommendedValue,
    String? destinationAddresses,
    String? originAddresses,
    DistanceEntity? distance,
    DurationEntity? duration,
  }) {
    return TimeAndDistanceValuesEntity(
      recommendedValue: recommendedValue ?? this.recommendedValue,
      destinationAddresses: destinationAddresses ?? this.destinationAddresses,
      originAddresses: originAddresses ?? this.originAddresses,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() {
    return 'TimeAndDistanceValuesEntity(recommendedValue: $recommendedValue, destinationAddresses: $destinationAddresses, originAddresses: $originAddresses, distance: $distance, duration: $duration)';
  }
}

class DistanceEntity {
  DistanceEntity({required this.text, required this.value});
  final String text;
  final double value;

  DistanceEntity copyWith({String? text, double? value}) {
    return DistanceEntity(text: text ?? this.text, value: value ?? this.value);
  }

  @override
  String toString() => 'DistanceEntity(text: $text, value: $value)';
}

class DurationEntity {
  DurationEntity({required this.text, required this.value});
  final String text;
  final double value;

  DurationEntity copyWith({String? text, double? value}) {
    return DurationEntity(text: text ?? this.text, value: value ?? this.value);
  }

  @override
  String toString() => 'DurationEntity(text: $text, value: $value)';
}
