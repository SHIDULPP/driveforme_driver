import 'package:driveforme_driver/src/data/models/trip_location_model.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchMapNavigation(TripLocation target) async {
  if (!target.hasCoordinates) return false;

  final lat = target.latitude!;
  final lng = target.longitude!;

  final nativeUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
  if (await canLaunchUrl(nativeUri)) {
    return launchUrl(nativeUri, mode: LaunchMode.externalApplication);
  }

  final webUri = Uri.https(
    'www.google.com',
    '/maps/dir/',
    {'api': '1', 'destination': '$lat,$lng', 'travelmode': 'driving'},
  );
  return launchUrl(webUri, mode: LaunchMode.externalApplication);
}
