import 'package:indriver_uber_clone/core/utils/parse_utils.dart';
import 'package:indriver_uber_clone/src/driver/domain/entities/client_request_response_entity.dart';

/// Tries to extract an estimated seconds value
///  from a ClientRequestResponseEntity.
///
/// Supported patterns:
///  - googleDistanceMatrix (Map or DTO-like) with duration.value (seconds)
///  - fields like timeDifference, time, duration
///  (treated as minutes unless heuristic suggests seconds)
/// Returns seconds or null.
int? extractEstimatedSecondsFromRequest(ClientRequestResponseEntity? request) {
  if (request == null) return null;

  try {
    final googleDistanceMatrix = (request as dynamic).googleDistanceMatrix;
    if (googleDistanceMatrix != null) {
      // Case A: backend returned a Map-like structure
      if (googleDistanceMatrix is Map) {
        // Common shapes:
        // 1) googleDistanceMatrix['duration']['value']
        // 2) googleDistanceMatrix['rows']?['elements']?['duration'] etc.
        final durationObject =
            googleDistanceMatrix['duration'] ??
            googleDistanceMatrix['rows']?['elements']?['duration'];
        final candidateValue = durationObject is Map
            ? (durationObject['value'] ?? durationObject['text'])
            : durationObject;
        final secondsFromCandidate = toIntSafe(candidateValue);
        if (secondsFromCandidate != null) return secondsFromCandidate;
      } else {
        // Case B: DTO-like object with .duration or .duration.value
        final dynamic dto = googleDistanceMatrix;
        final dynamic durationField = dto.duration;
        final dynamic candidateValue = durationField?.value ?? durationField;
        final secondsFromCandidate = toIntSafe(candidateValue);
        if (secondsFromCandidate != null) return secondsFromCandidate;
      }
    }

    // Fallback: fields on the request entity that
    // may represent minutes or seconds.
    final dynamic maybeTimeField =
        (request as dynamic).timeDifference ??
        (request as dynamic).time ??
        (request as dynamic).duration;
    if (maybeTimeField != null) {
      if (maybeTimeField is num) {
        final n = maybeTimeField.toDouble();
        // Heuristic:
        // - if n > 1000 => assume value in seconds
        // (common when backend mistakenly returns seconds)
        // - otherwise assume value in minutes and convert to seconds
        if (n > 1000) return n.round();
        return (n * 60).round();
      }

      if (maybeTimeField is String) {
        final parsed = double.tryParse(maybeTimeField.trim());
        if (parsed != null) {
          if (parsed > 1000) return parsed.round();
          return (parsed * 60).round();
        }
      }
    }
  } catch (_) {
    // swallow errors, prefer fallback behavior
  }

  return null;
}
