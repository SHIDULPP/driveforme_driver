import 'package:flutter/services.dart';

enum HapticImpact { light, medium, heavy, selection, none }

class HapticHelper {
  static Future<void> impact(HapticImpact impact) async {
    switch (impact) {
      case HapticImpact.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticImpact.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticImpact.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticImpact.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticImpact.none:
        break;
    }
  }
}
