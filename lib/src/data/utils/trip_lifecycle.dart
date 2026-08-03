import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> showCancelTripDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: kBlack.withValues(alpha: 0.45),
    builder: (context) => const _TripActionDialog(
      icon: Icons.error_outline_rounded,
      iconColor: kSosRed,
      title: 'Cancel trip?',
      body:
          'Are you sure you want to cancel this trip? This may affect your '
          'rating.',
      keepLabel: 'Keep trip',
      confirmLabel: 'Cancel trip',
      confirmColor: kSosRed,
    ),
  );
  return result == true;
}

/// Shared brand-styled confirmation dialog for destructive trip actions
/// (cancel trip, reject request) so all confirmations look consistent.
class _TripActionDialog extends StatelessWidget {
  const _TripActionDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.keepLabel,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String keepLabel;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: kStyle(kSemiBold, kSize18, color: kDarkText, height: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: kCaption13R.copyWith(color: kMutedText, height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDarkText,
                      side: const BorderSide(color: kCardBorder),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      keepLabel,
                      style: kStyle(kSemiBold, kSize14, color: kDarkText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: kWhite,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: kStyle(kSemiBold, kSize14, color: kWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirms rejecting an incoming trip request before it is dismissed.
Future<bool> showRejectTripDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: kBlack.withValues(alpha: 0.45),
    builder: (context) => const _TripActionDialog(
      icon: Icons.close_rounded,
      iconColor: kSosRed,
      title: 'Reject this trip?',
      body: 'You will not be assigned this trip. It will be offered to '
          'another driver nearby.',
      keepLabel: 'Go back',
      confirmLabel: 'Reject',
      confirmColor: kSosRed,
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

  final tripService = ref.read(tripScreenServiceProvider);
  final confirmed = await showCancelTripDialog(context);
  if (!confirmed || !context.mounted) return null;

  final response = await tripService.cancelTrip(
    tripMongoId,
    reason: reason,
  );

  if (!context.mounted) return null;

  if (!response.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Failed to cancel trip.')),
    );
    return null;
  }

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

/// Pops back to the existing [navBar] route when possible.
///
/// Creating a fresh [NavBar] via [pushNamedAndRemoveUntil] would re-run active
/// trip resume and can push the driver back onto a trip screen they just left.
void navigateToHomeAfterActiveTripEnds() {
  final navigator = NavigationService.navigatorKey.currentState;
  if (navigator == null) {
    NavigationService().pushNamedAndRemoveUntil('navBar');
    return;
  }

  var foundNavBar = false;
  navigator.popUntil((route) {
    final isNavBar = route.settings.name == 'navBar';
    if (isNavBar) foundNavBar = true;
    return isNavBar;
  });

  if (!foundNavBar) {
    NavigationService().pushNamedAndRemoveUntil('navBar');
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
