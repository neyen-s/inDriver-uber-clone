enum GenericHomeScaffoldSection {
  map,
  profile,
  driverCarInfo,
  roles,
  clientRequests,
}

enum SelectedField { origin, destination }

//enum RoutePhase { none, driverToPickup, pickupToDestination }

enum RoutePhases {
  created,
  acceopted,
  onTheWay,
  arrived,
  travelling,
  finished,
  canceled,
}
