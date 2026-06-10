String dobUiToApi(String ddMmYyyy) {
  final parts = ddMmYyyy.split('-');
  if (parts.length != 3) {
    throw FormatException('Date must be in DD-MM-YYYY format');
  }

  final day = parts[0].padLeft(2, '0');
  final month = parts[1].padLeft(2, '0');
  final year = parts[2];

  return '$year-$month-$day';
}

String genderUiToApi(String gender) => gender.toLowerCase();

String locationUiToApi(String location) => location.toLowerCase();
