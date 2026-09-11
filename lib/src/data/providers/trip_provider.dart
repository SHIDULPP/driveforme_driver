import 'package:DriveFormeDriver/src/data/apis/onboarding_api.dart';
import 'package:DriveFormeDriver/src/data/apis/trip_api.dart';
import 'package:DriveFormeDriver/src/data/models/trip_model.dart';
import 'package:DriveFormeDriver/src/data/services/secure_storage_service.dart';
import 'package:DriveFormeDriver/src/data/services/trip_socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final tripPreferenceProvider = StateProvider<String>((ref) => 'short_trip');

final driverOnlineProvider = StateProvider<bool>((ref) => true);

final dismissedTripIdsProvider = StateProvider<Set<String>>((ref) => {});

/// Live list of open trip requests for the driver.
///
/// Uses Socket.IO (`trip_available` / `trip_unavailable`) instead of polling.
/// Fetches once when the driver goes online or changes trip preference.
final availableTripsProvider =
    NotifierProvider<AvailableTripsNotifier, List<TripModel>>(
  AvailableTripsNotifier.new,
);

class AvailableTripsNotifier extends Notifier<List<TripModel>> {
  @override
  List<TripModel> build() {
    final socket = ref.watch(tripSocketServiceProvider);

    ref.listen(driverOnlineProvider, (previous, next) {
      if (next) {
        _startRealtime(socket);
      } else {
        _stopRealtime(socket);
      }
    }, fireImmediately: true);

    ref.listen(tripPreferenceProvider, (previous, next) {
      if (previous == next) return;
      if (ref.read(driverOnlineProvider)) {
        _loadInitialTrips();
      } else {
        state = _filterByPreference(state);
      }
    });

    ref.listen(dismissedTripIdsProvider, (previous, next) {
      state = _filterDismissed(state);
    });

    return const [];
  }

  void removeTrip(String tripId) {
    state = state.where((trip) => trip.id != tripId).toList();
  }

  void _startRealtime(TripSocketService socket) {
    socket.connect(
      onTripAvailable: _handleTripAvailable,
      onTripUnavailable: removeTrip,
    );
    socket.joinDriversRoom();
    _loadInitialTrips();
  }

  void _stopRealtime(TripSocketService socket) {
    socket.leaveDriversRoom();
    state = const [];
  }

  Future<void> _loadInitialTrips() async {
    if (!ref.read(driverOnlineProvider)) return;

    final tripType = ref.read(tripPreferenceProvider);
    final response = await ref.read(tripApiProvider).listAvailableTrips(
          tripType: tripType,
        );

    if (!response.success) return;

    final trips = _filterDismissed(
      _filterByPreference(response.data ?? const []),
    );
    if (!ref.read(driverOnlineProvider)) return;
    state = trips;
  }

  void _handleTripAvailable(Map<String, dynamic> data) {
    if (!ref.read(driverOnlineProvider)) return;

    final trip = TripModel.fromJson(data);
    if (trip.id.isEmpty) return;
    if (!_matchesPreference(trip)) return;
    if (ref.read(dismissedTripIdsProvider).contains(trip.id)) return;

    final updated = [
      trip,
      ...state.where((existing) => existing.id != trip.id),
    ]..sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
    state = updated;
  }

  bool _matchesPreference(TripModel trip) {
    final preferred = ref.read(tripPreferenceProvider);
    final type = trip.tripType.trim();
    if (type.isEmpty) return true;
    return type == preferred;
  }

  List<TripModel> _filterByPreference(List<TripModel> trips) =>
      trips.where(_matchesPreference).toList();

  List<TripModel> _filterDismissed(List<TripModel> trips) {
    final dismissed = ref.read(dismissedTripIdsProvider);
    return trips.where((trip) => !dismissed.contains(trip.id)).toList();
  }
}

void dismissTripRequest(WidgetRef ref, String tripId) {
  ref.read(dismissedTripIdsProvider.notifier).update(
        (ids) => {...ids, tripId},
      );
  ref.read(availableTripsProvider.notifier).removeTrip(tripId);
}

void setDriverOnline(WidgetRef ref, bool isOnline) {
  ref.read(driverOnlineProvider.notifier).state = isOnline;
  ref.read(secureStorageServiceProvider).saveDriverOnline(isOnline);
}

Future<void> loadDriverOnlinePreference(WidgetRef ref) async {
  final isOnline =
      await ref.read(secureStorageServiceProvider).getDriverOnline();
  ref.read(driverOnlineProvider.notifier).state = isOnline;
}

Future<void> loadTripPreference(WidgetRef ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  var preference = await storage.getTripPreference();

  // Prefer the value stored on the backend profile when available.
  try {
    final me = await ref.read(onboardingApiProvider).getMe();
    final remote = me.data?.preferredTripType;
    if (me.success && (remote == 'short_trip' || remote == 'long_trip')) {
      preference = remote!;
      await storage.saveTripPreference(preference);
    }
  } catch (_) {
    // Keep local preference if profile fetch fails.
  }

  ref.read(tripPreferenceProvider.notifier).state = preference;
}

Future<void> setTripPreference(WidgetRef ref, bool isShortTrip) async {
  final preference = isShortTrip ? 'short_trip' : 'long_trip';
  ref.read(tripPreferenceProvider.notifier).state = preference;
  await ref.read(secureStorageServiceProvider).saveTripPreference(preference);

  // Sync to backend so dispatch only targets matching drivers.
  try {
    final response =
        await ref.read(onboardingApiProvider).updateTripPreference(preference);
    if (!response.success) {
      // Keep local preference; backend will catch up on next successful sync.
    }
  } catch (_) {
    // Local preference still applies for in-app filtering.
  }
}
