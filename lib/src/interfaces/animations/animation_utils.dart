import 'package:flutter/material.dart';
import 'animation_types.dart';

/// Utility class for animation-related operations
class AnimationUtils {
  /// Get Curve from AnimationCurveType enum
  static Curve getCurve(AnimationCurveType curveType) {
    return switch (curveType) {
      AnimationCurveType.linear => Curves.linear,
      AnimationCurveType.easeIn => Curves.easeIn,
      AnimationCurveType.easeOut => Curves.easeOut,
      AnimationCurveType.easeInOut => Curves.easeInOut,
      AnimationCurveType.easeInExpo => Curves.easeInExpo,
      AnimationCurveType.easeOutExpo => Curves.easeOutExpo,
      AnimationCurveType.easeInCirc => Curves.easeInCirc,
      AnimationCurveType.easeOutCirc => Curves.easeOutCirc,
      AnimationCurveType.easeInBack => Curves.easeInBack,
      AnimationCurveType.easeOutBack => Curves.easeOutBack,
      AnimationCurveType.elasticIn => Curves.elasticIn,
      AnimationCurveType.elasticOut => Curves.elasticOut,
      AnimationCurveType.bounceIn => Curves.bounceIn,
      AnimationCurveType.bounceOut => Curves.bounceOut,
    };
  }

  /// Get default duration for animation type
  static Duration getDefaultDuration(AppAnimationType type) {
    return switch (type) {
      AppAnimationType.fadeIn ||
      AppAnimationType.pulse ||
      AppAnimationType.shimmer =>
        AnimationDuration.normal.value,
      AppAnimationType.slideInFromLeft ||
      AppAnimationType.slideInFromRight ||
      AppAnimationType.slideInFromTop ||
      AppAnimationType.slideInFromBottom =>
        AnimationDuration.normal.value,
      AppAnimationType.scaleUp || AppAnimationType.scaleDown => AnimationDuration.fast.value,
      AppAnimationType.bounce || AppAnimationType.elastic => AnimationDuration.slow.value,
      AppAnimationType.rotate => AnimationDuration.normal.value,
      AppAnimationType.fadeSlideInFromLeft ||
      AppAnimationType.fadeSlideInFromRight ||
      AppAnimationType.fadeSlideInFromTop ||
      AppAnimationType.fadeSlideInFromBottom =>
        AnimationDuration.normal.value,
      AppAnimationType.fadeScaleUp => AnimationDuration.normal.value,
    };
  }

  /// Get default curve for animation type
  static AnimationCurveType getDefaultCurve(AppAnimationType type) {
    return switch (type) {
      AppAnimationType.fadeIn => AnimationCurveType.easeIn,
      AppAnimationType.slideInFromLeft ||
      AppAnimationType.slideInFromRight ||
      AppAnimationType.slideInFromTop ||
      AppAnimationType.slideInFromBottom =>
        AnimationCurveType.easeOut,
      AppAnimationType.scaleUp => AnimationCurveType.easeOutBack,
      AppAnimationType.scaleDown => AnimationCurveType.easeInBack,
      AppAnimationType.bounce => AnimationCurveType.bounceOut,
      AppAnimationType.elastic => AnimationCurveType.elasticOut,
      AppAnimationType.rotate => AnimationCurveType.easeInOut,
      AppAnimationType.fadeSlideInFromLeft ||
      AppAnimationType.fadeSlideInFromRight ||
      AppAnimationType.fadeSlideInFromTop ||
      AppAnimationType.fadeSlideInFromBottom =>
        AnimationCurveType.easeOut,
      AppAnimationType.fadeScaleUp => AnimationCurveType.easeOutBack,
      AppAnimationType.pulse => AnimationCurveType.easeInOut,
      AppAnimationType.shimmer => AnimationCurveType.linear,
    };
  }
}
