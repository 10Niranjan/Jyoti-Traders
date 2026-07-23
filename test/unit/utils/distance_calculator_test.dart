import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/distance_calculator.dart';

void main() {
  test('distance between identical points is zero', () {
    expect(calculateDistanceKm(19.0760, 72.8777, 19.0760, 72.8777), 0);
  });

  test('distance between Mumbai and Pune is approximately 120km', () {
    // Known real-world distance, used as a sanity check on the Haversine
    // formula rather than an exact value (straight-line, not road distance).
    final km = calculateDistanceKm(19.0760, 72.8777, 18.5204, 73.8567);
    expect(km, closeTo(120, 10));
  });

  test('distance is symmetric regardless of point order', () {
    final forward = calculateDistanceKm(19.0760, 72.8777, 18.5204, 73.8567);
    final backward = calculateDistanceKm(18.5204, 73.8567, 19.0760, 72.8777);
    expect(forward, closeTo(backward, 0.0001));
  });
}
