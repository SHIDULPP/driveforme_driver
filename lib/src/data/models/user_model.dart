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

  const UserModel({
    required this.userId,
    required this.role,
    required this.phoneNumber,
    required this.onboardingStatus,
    required this.isPhoneVerified,
    required this.profile,
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
    );
  }
}
