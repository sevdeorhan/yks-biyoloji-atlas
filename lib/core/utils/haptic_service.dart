import 'package:flutter/services.dart';

class HapticService {
  HapticService._();

  static void success() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void light() => HapticFeedback.lightImpact();
  static void vibrate() => HapticFeedback.vibrate();
}
