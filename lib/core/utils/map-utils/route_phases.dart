import 'package:indriver_uber_clone/core/enums/enums.dart';

extension RoutePhasesExt on RoutePhases {
  /// Convert enum to the exact string the backend expects (UPPER_SNAKE)
  String toServerString() {
    switch (this) {
      case RoutePhases.created:
        return 'CREATED';
      case RoutePhases.acceopted:
        return 'ACCEPTED';
      case RoutePhases.onTheWay:
        return 'ON_THE_WAY';
      case RoutePhases.arrived:
        return 'ARRIVED';
      case RoutePhases.travelling:
        return 'TRAVELLING';
      case RoutePhases.finished:
        return 'FINISHED';
      case RoutePhases.canceled:
        return 'CANCELLED';
    }
  }
}

/// Helper to convert server string -> enum (nullable if unknown)
RoutePhases? routePhaseFromServerString(String? s) {
  if (s == null) return null;
  switch (s.toUpperCase()) {
    case 'CREATED':
      return RoutePhases.created;
    case 'ACCEPTED':
      return RoutePhases.acceopted;
    case 'ON_THE_WAY':
      return RoutePhases.onTheWay;
    case 'ARRIVED':
      return RoutePhases.arrived;
    case 'TRAVELLING':
      return RoutePhases.travelling;
    case 'FINISHED':
      return RoutePhases.finished;
    case 'CANCELLED':
      return RoutePhases.canceled;
    default:
      return null;
  }
}
