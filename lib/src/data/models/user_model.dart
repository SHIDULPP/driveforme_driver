class DriverVerification {
  final String aadhaarImageUrl;
  final String drivingLicenseImageUrl;
  final String livePhotoUrl;
  final DateTime? submittedAt;

  const DriverVerification({
    this.aadhaarImageUrl = '',
    this.drivingLicenseImageUrl = '',
    this.livePhotoUrl = '',
    this.submittedAt,
  });

  factory DriverVerification.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DriverVerification();

    DateTime? submittedAt;
    final rawSubmittedAt = json['submittedAt'];
    if (rawSubmittedAt is String && rawSubmittedAt.isNotEmpty) {
      submittedAt = DateTime.tryParse(rawSubmittedAt);
    }

    return DriverVerification(
      aadhaarImageUrl: json['aadhaarImageUrl'] as String? ?? '',
      drivingLicenseImageUrl:
          json['drivingLicenseImageUrl'] as String? ?? '',
      livePhotoUrl: json['livePhotoUrl'] as String? ?? '',
      submittedAt: submittedAt,
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
  final UserProfile profile;
  final DriverVerification driverVerification;

  const UserModel({
    required this.userId,
    required this.role,
    required this.phoneNumber,
    required this.onboardingStatus,
    required this.isPhoneVerified,
    required this.profile,
    required this.driverVerification,
  });

  bool get isApproved => onboardingStatus == 'approved';
  bool get needsProfile => onboardingStatus == 'profile_pending';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      onboardingStatus: json['onboardingStatus'] as String? ?? '',
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      profile: UserProfile.fromJson(
        json['profile'] as Map<String, dynamic>?,
      ),
      driverVerification: DriverVerification.fromJson(
        json['driverVerification'] as Map<String, dynamic>?,
      ),
    );
  }
}
