import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> showCancelTripDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel trip?'),
      content: const Text(
        'Are you sure you want to cancel this trip? This may affect your rating.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep trip'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancel trip'),
        ),
      ],
    ),
  );
  return result == true;
}

Future<TripModel?> cancelTripWithDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String tripMongoId,
  String? reason,
}) async {
  if (tripMongoId.isEmpty) return null;

  final confirmed = await showCancelTripDialog(context);
  if (!confirmed || !context.mounted) return null;

  final response = await ref.read(tripApiProvider).cancelTrip(
        tripMongoId,
        reason: reason ?? 'Cancelled by driver',
      );

  if (!context.mounted) return null;

  if (!response.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Failed to cancel trip.')),
    );
    return null;
  }

  await ref.read(secureStorageServiceProvider).clearActiveTripId();
  ref.read(activeTripProvider.notifier).clear();

  return response.data;
}

void openChatScreen({
  required String receiverId,
  required String receiverName,
  String? tripId,
}) {
  if (receiverId.isEmpty) return;
  NavigationService().pushNamed(
    'chat_screen',
    arguments: {
      'receiverId': receiverId,
      'receiverName': receiverName,
      if (tripId != null && tripId.isNotEmpty) 'tripId': tripId,
      'participantName': receiverName,
    },
  );
}

Future<void> launchPhoneCall(String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (cleaned.isEmpty) return;
  final uri = Uri(scheme: 'tel', path: cleaned);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> navigateToActiveTrip(WidgetRef ref, TripModel trip) async {
  await ref.read(activeTripProvider.notifier).setActiveTrip(trip.id, trip: trip);
  final target = tripNavigationTarget(trip);
  if (target == null) return;
  NavigationService().pushNamed(
    target.route,
    arguments: target.arguments,
  );
}
