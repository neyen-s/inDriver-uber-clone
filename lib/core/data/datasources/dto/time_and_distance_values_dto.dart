import 'package:indriver_uber_clone/core/domain/entities/time_and_distance_values_entity.dart';

class TimeAndDistanceValuesDto extends TimeAndDistanceValuesEntity {
  TimeAndDistanceValuesDto({
    required super.recommendedValue,
    required super.destinationAddresses,
    required super.originAddresses,
    required super.distance,
    required super.duration,
  });

  factory TimeAndDistanceValuesDto.fromJson(Map<String, dynamic> json) {
    return TimeAndDistanceValuesDto(
      recommendedValue: (json['recommended_value'] as num).toDouble(),
      destinationAddresses: json['destination_addresses'] as String,
      originAddresses: json['origin_addresses'] as String,
      distance: DistanceDto.fromJson(json['distance'] as Map<String, dynamic>),
      duration: DurationDto.fromJson(json['duration'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_value': recommendedValue,
      'destination_addresses': destinationAddresses,
      'origin_addresses': originAddresses,
      'distance': {'text': distance.text, 'value': distance.value},
      'duration': {'text': duration.text, 'value': duration.value},
    };
  }

  @override
  String toString() {
    return 'TimeAndDistanceValuesDto(recommendedValue: $recommendedValue,'
        ' destinationAddresses: $destinationAddresses,'
        ' originAddresses: $originAddresses,'
        ' distance: $distance, duration: $duration)';
  }
}

class DurationDto extends DurationEntity {
  DurationDto({required super.text, required super.value});

  factory DurationDto.fromJson(Map<String, dynamic> json) {
    return DurationDto(
      text: json['text'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'value': value};
  }

  @override
  String toString() => 'DurationDto(text: $text, value: $value)';
}

class DistanceDto extends DistanceEntity {
  DistanceDto({required super.text, required super.value});

  factory DistanceDto.fromJson(Map<String, dynamic> json) {
    return DistanceDto(
      text: json['text'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'value': value};
  }

  @override
  String toString() => 'DistanceDto(text: $text, value: $value)';
}
