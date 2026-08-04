class DriverReviewModel {
  final String tripId;
  final double stars;
  final String comment;
  final DateTime? ratedAt;

  const DriverReviewModel({
    required this.tripId,
    required this.stars,
    this.comment = '',
    this.ratedAt,
  });

  factory DriverReviewModel.fromJson(Map<String, dynamic> json) {
    return DriverReviewModel(
      tripId: json['tripId']?.toString() ?? '',
      stars: _toDouble(json['stars']) ?? 0,
      comment: json['comment']?.toString() ?? '',
      ratedAt: _parseDate(json['ratedAt']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class DriverRatingsSummary {
  final double? driverRating;
  final List<DriverReviewModel> reviews;

  const DriverRatingsSummary({
    this.driverRating,
    this.reviews = const [],
  });

  factory DriverRatingsSummary.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final rawReviews = json['reviews'];
    final reviews = rawReviews is List
        ? rawReviews
              .whereType<Map>()
              .map((item) => DriverReviewModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
        : const <DriverReviewModel>[];

    double? storedRating;
    if (driver is Map) {
      final value = driver['rating'];
      if (value is num) {
        storedRating = value.toDouble();
      } else if (value is String) {
        storedRating = double.tryParse(value);
      }
    }

    return DriverRatingsSummary(
      driverRating: storedRating,
      reviews: reviews,
    );
  }

  /// Average of customer review stars, rounded to 1 decimal.
  double? get averageFromReviews {
    if (reviews.isEmpty) return null;
    final sum = reviews.fold<double>(0, (total, r) => total + r.stars);
    return double.parse((sum / reviews.length).toStringAsFixed(1));
  }
}
