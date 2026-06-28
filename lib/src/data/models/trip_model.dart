import 'package:intl/intl.dart';

import 'package:driveforme_driver/src/data/models/trip_location_model.dart';

class TripModel {
  static const requestExpiryMinutes = 5;

  final String id;
  final String tripNumber;
  final String status;
  final String tripDirection;
  final String tripType;
  final String rideTime;
  final TripLocation pickupLocation;
  final TripLocation? dropoffLocation;
  final double? distanceKm;
  final String? estimatedDurationLabel;
  final int durationValue;
  final String durationUnit;
  final DateTime? pickupAt;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final double? priceMinimum;
  final double? priceMaximum;
  final String currency;
  final String paymentMethod;
  final String customerId;
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
    required this.pickupLocation,
    this.dropoffLocation,
    this.distanceKm,
    this.estimatedDurationLabel,
    required this.durationValue,
    required this.durationUnit,
    this.pickupAt,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.priceMinimum,
    this.priceMaximum,
    this.currency = 'INR',
    required this.paymentMethod,
    this.customerId = '',
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
    final timeline = json['timeline'];
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
      pickupLocation: routeMap != null
          ? TripLocation.fromDynamic(routeMap['pickupLocation'])
          : const TripLocation.empty(),
      dropoffLocation: routeMap != null
          ? _optionalLocation(routeMap['dropoffLocation'])
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
      startedAt: timeline is Map ? _parseDate(timeline['startedAt']) : null,
      completedAt: timeline is Map ? _parseDate(timeline['completedAt']) : null,
      cancelledAt: timeline is Map ? _parseDate(timeline['cancelledAt']) : null,
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
      customerId: _userId(customer) ?? '',
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

  String get pickupAddress => pickupLocation.address;

  String? get dropoffAddress {
    final address = dropoffLocation?.address ?? '';
    return address.isEmpty ? null : address;
  }

  bool get isLongTrip => tripType == 'long_trip';

  bool get isOneWay => tripDirection == 'one_way';

  bool get isDriverAssigned => status == 'driver_assigned';

  bool get isScheduled => status == 'scheduled' || rideTime == 'scheduled';

  bool get isInProgress => status == 'in_progress';

  bool get isCompleted => status == 'completed';

  bool get isCancelled => status == 'cancelled';

  /// True when the scheduled pickup minute has arrived (or passed).
  bool get isPickupTimeReached {
    if (pickupAt == null) return rideTime == 'now';
    final now = _truncateToMinute(DateTime.now());
    final scheduled = _truncateToMinute(pickupAt!);
    return !now.isBefore(scheduled);
  }

  /// Scheduled trip still waiting for its pickup window.
  bool get isFutureScheduled =>
      isScheduled && !isPickupTimeReached && !isCancelled;

  /// Trips the driver should treat as active (ongoing tab / resume flow).
  bool get isOngoingForDriver =>
      isInProgress || isDriverAssigned || (isScheduled && isPickupTimeReached);

  String get startsInLabel {
    if (pickupAt == null || isPickupTimeReached) return '';
    final remaining = pickupAt!.difference(DateTime.now());
    if (remaining.isNegative || remaining.inSeconds <= 0) return '';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) return '$hours hrs $minutes min';
    if (minutes > 0) return '$minutes min';
    return 'less than 1 min';
  }

  static DateTime _truncateToMinute(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
  }

  String get displayTripId =>
      tripNumber.isNotEmpty ? '# $tripNumber' : '# ${id.substring(0, 8)}';

  String get tripTypeChipLabel => isLongTrip ? 'Long Trip' : 'Short Trip';

  String get tripTypeBadgeLabel => isLongTrip ? 'LONG TRIP' : 'SHORT TRIP';

  String get displayEarnings => displayPrice;

  String get displayPrice {
    final amount = priceMinimum ?? priceMaximum;
    if (amount == null) return '—';
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  String get vehicleTypeLabel {
    final trans = _titleCase(transmission);
    if (trans.isEmpty) return '—';
    return trans;
  }

  String get vehicleTypesLabel {
    final type = _titleCase(vehicleType);
    final trans = _titleCase(transmission);
    if (type.isEmpty && trans.isEmpty) return '—';
    if (type.isEmpty) return trans;
    if (trans.isEmpty) return type;
    return '$trans + $type';
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

  String get customerDisplayName =>
      customerName.isNotEmpty ? customerName : 'Vehicle owner';

  String get earningsLabel => displayPrice;

  String get routeSummaryLine {
    final pickup = pickupAddress.isNotEmpty ? pickupAddress : 'Pickup';
    final dropoff = dropoffAddress ?? pickup;
    return '$pickup  →  $dropoff';
  }

  String get elapsedDurationLabel {
    if (startedAt == null) return durationLabel;
    final end = completedAt ?? DateTime.now();
    final elapsed = end.difference(startedAt!);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    if (hours > 0) return '$hours h $minutes min';
    return '$minutes min';
  }

  String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('d MMMM, hh:mm a').format(date);
  }

  String get paymentTypeKey =>
      paymentMethod == 'pay_online' || paymentMethod == 'upi'
          ? 'online'
          : 'offline';

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

  Map<String, dynamic> toDriverArrivedArguments() => {
        'tripMongoId': id,
        'tripId': displayTripId,
        'customerId': customerId,
        'customerName': customerDisplayName,
        'customerPhone': customerPhone,
        'pickup': pickupAddress,
        'dropoff': dropoffAddress ?? pickupAddress,
        'vehicleNumber': vehicleNumber,
        'vehicleName': vehicleName,
        'distance': distanceLabel,
        'duration': durationLabel,
        'price': displayPrice,
      };

  Map<String, dynamic> toOtpArguments() => {
        'tripMongoId': id,
      };

  Map<String, dynamic> toEndTripArguments() => {
        'tripMongoId': id,
        'tripId': displayTripId,
        'customerId': customerId,
        'customerName': customerDisplayName,
        'customerPhone': customerPhone,
        'pickup': pickupAddress,
        'dropoff': dropoffAddress ?? pickupAddress,
        'headingTo': dropoffAddress ?? pickupAddress,
        'distance': distanceLabel,
        'duration': durationLabel,
        'price': displayPrice,
        'startedAt': startedAt?.toIso8601String(),
        'paymentMethod': paymentMethod,
      };

  Map<String, dynamic> toTripCompletedArguments() => {
        'tripMongoId': id,
        'tripId': displayTripId,
        'routeSummary': routeSummaryLine,
        'elapsedDuration': elapsedDurationLabel,
        'totalEarned': displayPrice,
        'baseFareLabel': 'Base fare ($durationLabel)',
        'baseFareAmount': displayPrice,
        'extraTimeLabel': 'Extra Time',
        'extraTimeAmount': '—',
        'totalAmount': displayPrice,
        'paymentMethod': paymentMethod,
      };

  Map<String, dynamic> toCashCollectedArguments() => {
        'tripMongoId': id,
        'collectedAmount': displayPrice,
      };

  Map<String, dynamic> toTripDetailsArguments() => {
        'tripMongoId': id,
        'tripId': displayTripId,
        'status': status,
        'customerName': customerDisplayName,
        'customerPhone': customerPhone,
        'customerId': customerId,
        'pickup': pickupAddress,
        'dropoff': dropoffAddress ?? pickupAddress,
        'distance': distanceLabel,
        'duration': durationLabel,
        'price': displayPrice,
        'pickupAt': pickupAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'tripTypeLabel': tripTypeBadgeLabel,
      };

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static TripLocation? _optionalLocation(dynamic location) {
    if (location == null) return null;
    final parsed = TripLocation.fromDynamic(location);
    if (!parsed.hasAddress && !parsed.hasCoordinates) return null;
    return parsed;
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

  static String? _userId(dynamic user) {
    if (user is Map) {
      final id = user['_id'] ?? user['id'] ?? user['userId'];
      if (id != null) return id.toString();
    }
    return null;
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
