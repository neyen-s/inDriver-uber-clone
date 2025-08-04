double calculateTripPrice(double distanceKm, int durationMinutes) {
  const baseFare = 2.0;
  const costPerKm = 0.75;
  const costPerMinute = 0.25;

  final total =
      baseFare + (distanceKm * costPerKm) + (durationMinutes * costPerMinute);

  return double.parse(total.toStringAsFixed(2));
}
