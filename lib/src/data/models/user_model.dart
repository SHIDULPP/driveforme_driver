String _normalizeOnboardingStatus(String status) => status.trim().toLowerCase();

double _parseWalletBalance(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class AdminReview {
  final String status;
  final String notes;
  final DateTime? reviewedAt;

  const AdminReview({
    this.status = '',
    this.notes = '',
    this.reviewedAt,
  });

  factory AdminReview.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AdminReview();

    DateTime? reviewedAt;
    final raw = json['reviewedAt'];
    if (raw is String && raw.isNotEmpty) {
      reviewedAt = DateTime.tryParse(raw);
    }

    return AdminReview(
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      reviewedAt: reviewedAt,
    );
  }
}

class DocumentAiCheck {
  final bool isBlurred;
  final bool isPartial;
  final bool hasSunglasses;
  final String notes;

  const DocumentAiCheck({
    this.isBlurred = false,
    this.isPartial = false,
    this.hasSunglasses = false,
    this.notes = '',
  });

  factory DocumentAiCheck.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DocumentAiCheck();

    return DocumentAiCheck(
      isBlurred: json['isBlurred'] as bool? ?? false,
      isPartial: json['isPartial'] as bool? ?? false,
      hasSunglasses: json['hasSunglasses'] as bool? ?? false,
      notes: json['notes']?.toString() ?? '',
    );
  }

  String rejectionReason(String fallback) {
    final trimmedNotes = notes.trim();
    if (trimmedNotes.isNotEmpty) return trimmedNotes;

    final issues = <String>[];
    if (isBlurred) issues.add('The document is blurry');
    if (isPartial) issues.add('text details not clearly visible');
    if (hasSunglasses) {
      issues.add('sunglasses are not allowed in the live photo');
    }
    if (issues.isEmpty) return fallback;

    if (issues.length == 1) return '${issues.first}.';
    return '${issues.first}, ${issues.sublist(1).join(', ')}.';
  }
}

class DriverVerification {
  final String aadhaarImageUrl;
  final String drivingLicenseImageUrl;
  final String livePhotoUrl;
  final DateTime? submittedAt;
  final DocumentAiCheck aadhaarCheck;
  final DocumentAiCheck drivingLicenseCheck;
  final DocumentAiCheck livePhotoCheck;
  final String aiVerificationNotes;

  const DriverVerification({
    this.aadhaarImageUrl = '',
    this.drivingLicenseImageUrl = '',
    this.livePhotoUrl = '',
    this.submittedAt,
    this.aadhaarCheck = const DocumentAiCheck(),
    this.drivingLicenseCheck = const DocumentAiCheck(),
    this.livePhotoCheck = const DocumentAiCheck(),
    this.aiVerificationNotes = '',
  });

  factory DriverVerification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DriverVerification();

    DateTime? submittedAt;
    final rawSubmittedAt = json['submittedAt'];
    if (rawSubmittedAt is String && rawSubmittedAt.isNotEmpty) {
      submittedAt = DateTime.tryParse(rawSubmittedAt);
    }

    final aiChecks = json['aiChecks'] as Map<String, dynamic>?;

    return DriverVerification(
      aadhaarImageUrl: json['aadhaarImageUrl'] as String? ?? '',
      drivingLicenseImageUrl:
          json['drivingLicenseImageUrl'] as String? ?? '',
      livePhotoUrl: json['livePhotoUrl'] as String? ?? '',
      submittedAt: submittedAt,
      aadhaarCheck: DocumentAiCheck.fromJson(
        aiChecks?['aadhaarCard'] as Map<String, dynamic>? ??
            json['aadhaarCard'] as Map<String, dynamic>?,
      ),
      drivingLicenseCheck: DocumentAiCheck.fromJson(
        aiChecks?['drivingLicense'] as Map<String, dynamic>? ??
            json['drivingLicense'] as Map<String, dynamic>?,
      ),
      livePhotoCheck: DocumentAiCheck.fromJson(
        aiChecks?['livePhoto'] as Map<String, dynamic>? ??
            json['livePhoto'] as Map<String, dynamic>?,
      ),
      aiVerificationNotes: json['aiVerificationNotes']?.toString() ?? '',
    );
  }

  bool get hasAllDocuments =>
      aadhaarImageUrl.isNotEmpty &&
      drivingLicenseImageUrl.isNotEmpty &&
      livePhotoUrl.isNotEmpty;
}

class UserProfile {
  final String fullName;
  final String email;
  final DateTime? dateOfBirth;
  final String gender;
  final String location;

  const UserProfile({
    this.fullName = '',
    this.email = '',
    this.dateOfBirth,
    this.gender = '',
    this.location = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserProfile();

    DateTime? dob;
    final rawDob = json['dateOfBirth'];
    if (rawDob is String && rawDob.isNotEmpty) {
      dob = DateTime.tryParse(rawDob);
    }

    return UserProfile(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: dob,
      gender: json['gender'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}

class UserModel {
  final String userId;
  final String role;
  final String phoneNumber;
  final String onboardingStatus;
  final bool isPhoneVerified;
  final double walletBalance;
  final double rating;
  final int totalTrips;
  final double todayEarnings;
  final UserProfile profile;
  final DriverVerification driverVerification;
  final AdminReview adminReview;
  final String referralCode;

  const UserModel({
    required this.userId,
    required this.role,
    required this.phoneNumber,
    required this.onboardingStatus,
    required this.isPhoneVerified,
    this.walletBalance = 0,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.todayEarnings = 0,
    required this.profile,
    required this.driverVerification,
    this.adminReview = const AdminReview(),
    this.referralCode = '',
  });

  bool get isApproved => effectiveOnboardingStatus == 'approved';
  bool get needsProfile => effectiveOnboardingStatus == 'profile_pending';

  bool get isOnboardingRejected =>
      _normalizeOnboardingStatus(onboardingStatus) == 'rejected' ||
      _normalizeOnboardingStatus(adminReview.status) == 'rejected';

  String get effectiveOnboardingStatus =>
      isOnboardingRejected ? 'rejected' : _normalizeOnboardingStatus(onboardingStatus);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      onboardingStatus: json['onboardingStatus'] as String? ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      walletBalance: _parseWalletBalance(json['walletBalance']),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0,
      profile: UserProfile.fromJson(
        json['profile'] as Map<String, dynamic>?,
      ),
      driverVerification: DriverVerification.fromJson(
        json['driverVerification'] as Map<String, dynamic>?,
      ),
      adminReview: AdminReview.fromJson(
        json['adminReview'] as Map<String, dynamic>?,
      ),
      referralCode: json['referralCode']?.toString() ?? '',
    );
  }
}
