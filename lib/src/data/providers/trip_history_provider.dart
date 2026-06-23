import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TripHistoryTab { ongoing, upcoming, completed, cancelled }

final tripHistoryProvider =
    FutureProvider.family<List<TripModel>, TripHistoryTab>((ref, tab) async {
  final api = ref.watch(tripApiProvider);

  switch (tab) {
    case TripHistoryTab.ongoing:
      final inProgress = await api.listOngoingTrips();
      final assigned = await api.listAssignedTrips();
      if (!inProgress.success) {
        throw Exception(inProgress.message ?? 'Failed to load ongoing trips.');
      }
      if (!assigned.success) {
        throw Exception(assigned.message ?? 'Failed to load assigned trips.');
      }
      return [
        ...(inProgress.data ?? []),
        ...(assigned.data ?? []),
      ];
    case TripHistoryTab.upcoming:
      final response = await api.listUpcomingTrips();
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load upcoming trips.');
      }
      return response.data ?? [];
    case TripHistoryTab.completed:
      final response = await api.listCompletedTrips();
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load completed trips.');
      }
      return response.data ?? [];
    case TripHistoryTab.cancelled:
      final response = await api.listCancelledTrips();
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load cancelled trips.');
      }
      return response.data ?? [];
  }
});
