import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripLocation {
  final String address;
  final double? latitude;
  final double? longitude;

  const TripLocation({
    this.address = '',
    this.latitude,
    this.longitude,
  });

  const TripLocation.empty() : this();

  bool get hasAddress => address.trim().isNotEmpty;

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite;

  LatLng? get latLng =>
      hasCoordinates ? LatLng(latitude!, longitude!) : null;

  factory TripLocation.fromDynamic(dynamic value) {
    if (value is! Map) {
      return const TripLocation.empty();
    }

    final map = Map<String, dynamic>.from(value);
    return TripLocation(
      address: map['address']?.toString().trim() ?? '',
      latitude: _toDouble(map['latitude'] ?? map['lat']),
      longitude: _toDouble(map['longitude'] ?? map['lng'] ?? map['lon']),
    );
  }

  factory TripLocation.fromAddress(String address) {
    return TripLocation(address: address.trim());
  }

  factory TripLocation.fromPosition({
    required double latitude,
    required double longitude,
    String address = '',
  }) {
    return TripLocation(
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        if (address.isNotEmpty) 'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  TripLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return TripLocation(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get displayLabel {
    if (!hasAddress) return 'Current location';

    final parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return address;
    if (parts.length == 1) return parts.first;
    return '${parts[0]}, ${parts[1]}';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
