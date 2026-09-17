String dobUiToApi(String ddMmYyyy) {
  final parts = ddMmYyyy.split('/');
  if (parts.length != 3) {
    throw FormatException('Date must be in DD/MM/YYYY format');
  }

  final day = parts[0].padLeft(2, '0');
  final month = parts[1].padLeft(2, '0');
  final year = parts[2];

  return '$year-$month-$day';
}

String genderUiToApi(String gender) => gender.toLowerCase();

String locationUiToApi(String location) => location.toLowerCase();

/// Validates driver Date of Birth for onboarding and profile updates.
/// Ensures input is in DD/MM/YYYY format, is a valid calendar date,
/// and that the driver meets the minimum age requirement (default: 18 years).
String? validateDriverDob(String? value, {int minAge = 18}) {
  if (value == null || value.trim().isEmpty) {
    return 'Date of birth is required';
  }

  final trimmed = value.trim();
  final parts = trimmed.split('/');
  if (parts.length != 3) {
    return 'Enter date as DD/MM/YYYY';
  }

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) {
    return 'Invalid date format';
  }

  // Basic calendar boundary checks
  if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900) {
    return 'Invalid date format';
  }

  // Exact calendar validity check (e.g., 31/02/2000 or leap year check)
  final dob = DateTime(year, month, day);
  if (dob.year != year || dob.month != month || dob.day != day) {
    return 'Invalid date format';
  }

  final now = DateTime.now();

  // Future date check
  if (dob.isAfter(now)) {
    return 'Date of birth cannot be in the future';
  }

  // Exact age calculation
  var age = now.year - dob.year;
  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
    age--;
  }

  if (age < minAge) {
    return 'Driver must be at least $minAge years old';
  }

  return null;
}
