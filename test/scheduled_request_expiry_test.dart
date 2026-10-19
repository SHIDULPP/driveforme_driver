import 'package:DriveFormeDriver/src/data/models/trip_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 19, 10);
  TripModel trip({
    String status = 'scheduled',
    String rideTime = 'scheduled',
    String? pickup,
  }) => TripModel.fromJson({
    '_id': 'test-trip',
    'status': status,
    'tripDetails': {'rideTime': rideTime, 'pickupAt': pickup},
  });

  test('old August request is expired', () {
    expect(trip(pickup: '2026-08-20T10:00:00Z').canBeOfferedAt(now), isFalse);
  });
  test('request expires exactly at pickup time', () {
    final request = trip(pickup: now.toIso8601String());
    expect(
      request.canBeOfferedAt(now.subtract(const Duration(seconds: 1))),
      isTrue,
    );
    expect(request.canBeOfferedAt(now), isFalse);
  });
  test('scheduled request requires a valid pickup date', () {
    expect(trip().canBeOfferedAt(now), isFalse);
    expect(trip(pickup: 'invalid').canBeOfferedAt(now), isFalse);
  });
  test('pending scheduled request also expires', () {
    expect(
      trip(
        status: 'pending_assignment',
        pickup: '2026-08-20T10:00:00Z',
      ).canBeOfferedAt(now),
      isFalse,
    );
  });
  test('immediate requests remain available', () {
    expect(
      trip(status: 'pending_assignment', rideTime: 'now').canBeOfferedAt(now),
      isTrue,
    );
  });
  test('finished or assigned trips are never offered', () {
    for (final status in [
      'completed',
      'cancelled',
      'in_progress',
      'driver_assigned',
    ]) {
      expect(
        trip(
          status: status,
          pickup: '2027-08-20T10:00:00Z',
        ).canBeOfferedAt(now),
        isFalse,
      );
    }
  });
}
