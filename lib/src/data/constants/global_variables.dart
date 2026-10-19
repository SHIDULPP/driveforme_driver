class GlobalVariables {
  static String preferredLanguage = 'en';

  static Future<void> initialize(
    Future<String?> Function() getPreferredLanguage,
  ) async {
    try {
      final language = await getPreferredLanguage();
      preferredLanguage = language ?? 'en';
    } catch (_) {
      preferredLanguage = 'en';
    }
  }

  static void setPreferredLanguage(String language) {
    preferredLanguage = language;
  }

  static String getPreferredLanguage() {
    return preferredLanguage;
  }
}
