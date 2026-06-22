class TripModel {
  static const requestExpiryMinutes = 5;

  final String id;
  final String tripNumber;
  final String status;
  final String tripDirection;
  final String tripType;
  final String rideTime;
  final String pickupAddress;
  final String? dropoffAddress;
  final double? distanceKm;
  final String? estimatedDurationLabel;
  final int durationValue;
  final String durationUnit;
  final DateTime? pickupAt;
  final DateTime? createdAt;
  final double? priceMinimum;
  final double? priceMaximum;
  final String currency;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final String vehicleName;
  final String vehicleNumber;
  final String vehicleType;
  final String transmission;

  const TripModel({
    required this.id,
    required this.tripNumber,
    required this.status,
    required this.tripDirection,
    required this.tripType,
    required this.rideTime,
    required this.pickupAddress,
    this.dropoffAddress,
    this.distanceKm,
    this.estimatedDurationLabel,
    required this.durationValue,
    required this.durationUnit,
    this.pickupAt,
    this.createdAt,
    this.priceMinimum,
    this.priceMaximum,
    this.currency = 'INR',
    required this.paymentMethod,
    this.customerName = '',
    this.customerPhone = '',
    this.vehicleName = '',
    this.vehicleNumber = '',
    this.vehicleType = '',
    this.transmission = '',
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final route = json['route'];
    final routeMap = route is Map ? Map<String, dynamic>.from(route) : null;
    final routeSummary = routeMap != null ? _asMap(routeMap['summary']) : null;
    final tripDetails = json['tripDetails'];
    final priceEstimate = tripDetails is Map ? tripDetails['priceEstimate'] : null;
    final vehicleDetails = json['vehicleDetails'];
    final customer = json['customer'] ?? json['vehicleOwner'];

    return TripModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tripNumber: json['tripNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      tripDirection: tripDetails is Map
          ? tripDetails['tripDirection']?.toString() ?? 'one_way'
          : 'one_way',
      tripType: tripDetails is Map
          ? tripDetails['tripType']?.toString() ?? 'short_trip'
          : 'short_trip',
      rideTime: tripDetails is Map
          ? tripDetails['rideTime']?.toString() ?? 'now'
          : 'now',
      pickupAddress: routeMap != null
          ? _locationAddress(routeMap['pickupLocation'])
          : '',
      dropoffAddress: routeMap != null
          ? _optionalLocationAddress(routeMap['dropoffLocation'])
          : null,
      distanceKm: _toDouble(routeSummary?['distanceKm']),
      estimatedDurationLabel:
          routeSummary?['estimatedDurationLabel']?.toString(),
      durationValue: tripDetails is Map
          ? (tripDetails['durationValue'] as num?)?.toInt() ?? 1
          : 1,
      durationUnit: tripDetails is Map
          ? tripDetails['durationUnit']?.toString() ?? 'hours'
          : 'hours',
      pickupAt: tripDetails is Map ? _parseDate(tripDetails['pickupAt']) : null,
      createdAt: _parseDate(json['createdAt']),
      priceMinimum: priceEstimate is Map
          ? _toDouble(priceEstimate['minimum'])
          : null,
      priceMaximum: priceEstimate is Map
          ? _toDouble(priceEstimate['maximum'])
          : null,
      currency: priceEstimate is Map
          ? priceEstimate['currency']?.toString() ?? 'INR'
          : 'INR',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      customerName: _userName(customer) ?? '',
      customerPhone: _userPhone(customer) ?? '',
      vehicleName: vehicleDetails is Map
          ? vehicleDetails['vehicleName']?.toString() ?? ''
          : '',
      vehicleNumber: vehicleDetails is Map
          ? vehicleDetails['vehicleNumber']?.toString() ?? ''
          : '',
      vehicleType: vehicleDetails is Map
          ? vehicleDetails['vehicleType']?.toString() ?? ''
          : '',
      transmission: vehicleDetails is Map
          ? vehicleDetails['transmission']?.toString() ?? ''
          : '',
    );
  }

  bool get isLongTrip => tripType == 'long_trip';

  String get tripTypeChipLabel => isLongTrip ? 'Long Trip' : 'Short Trip';

  String get tripTypeBadgeLabel => isLongTrip ? 'LONG TRIP' : 'SHORT TRIP';

  String get displayEarnings {
    final amount = priceMinimum ?? priceMaximum;
    if (amount == null) return '—';
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  String get durationLabel {
    if (estimatedDurationLabel != null && estimatedDurationLabel!.isNotEmpty) {
      return estimatedDurationLabel!;
    }
    if (durationUnit == 'days') {
      return durationValue == 1 ? '1 day' : '$durationValue days';
    }
    return durationValue == 1 ? '1 hr' : '$durationValue hrs';
  }

  String get distanceLabel {
    if (distanceKm == null) return '—';
    final value = distanceKm!;
    final formatted = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted km';
  }

  String get vehicleTypeLabel {
    final trans = _titleCase(transmission);
    if (trans.isEmpty) return '—';
    return trans;
  }

  String get customerDisplayName =>
      customerName.isNotEmpty ? customerName : 'Customer';

  DateTime? get expiresAt => createdAt?.add(
        const Duration(minutes: requestExpiryMinutes),
      );

  Duration get remainingTime {
    final expiry = expiresAt;
    if (expiry == null) return Duration.zero;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  bool get isExpired => remainingTime == Duration.zero && createdAt != null;

  String get countdownLabel {
    final remaining = remainingTime;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get pickupDistanceSubtitle => 'Pickup, $distanceLabel away';

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _locationAddress(dynamic location) {
    if (location is Map) {
      return location['address']?.toString().trim() ?? '';
    }
    return '';
  }

  static String? _optionalLocationAddress(dynamic location) {
    final address = _locationAddress(location);
    return address.isEmpty ? null : address;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _userName(dynamic user) {
    if (user is Map) {
      final profile = user['profile'];
      if (profile is Map && profile['fullName'] != null) {
        final name = profile['fullName'].toString().trim();
        if (name.isNotEmpty) return name;
      }
    }
    return null;
  }

  static String? _userPhone(dynamic user) {
    if (user is Map && user['phoneNumber'] != null) {
      return user['phoneNumber'].toString();
    }
    return null;
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split('_')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
