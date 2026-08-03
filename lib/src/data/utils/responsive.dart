import 'package:flutter/material.dart';

/// Design reference width (logical px) used across the app.
const double kDesignWidth = 375;

/// Width scale factor clamped so layouts stay stable on very small/large phones.
double responsiveScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / kDesignWidth).clamp(0.88, 1.12);
}

/// Scales a layout dimension (padding, height, icon size, etc.) to the screen width.
double responsiveSize(BuildContext context, double value) =>
    value * responsiveScale(context);

/// Scales a font size to the screen width. Prefer relying on [scaledMediaQuery]
/// in the app root so most [Text] widgets inherit scaling automatically.
double responsiveFontSize(BuildContext context, double value) =>
    value * responsiveScale(context);

/// Horizontal screen padding used by main tab screens.
double responsiveHorizontalPadding(BuildContext context) =>
    responsiveSize(context, 20);

/// Bottom padding for scrollable main-tab content above the floating nav bar.
double responsiveScaffoldBottomPadding(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  // Nav bar 64 + gap (inset or 16) + small content breathing room.
  final gap = bottomInset > 0 ? bottomInset : 16.0;
  return 64 + gap + 12;
}

/// Total height occupied by the floating bottom navigation bar (including safe area gap).
double responsiveFloatingNavTotalHeight(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  final gap = bottomInset > 0 ? bottomInset : 16.0;
  return 64 + gap;
}

/// Applies width-based text scaling and clamps system accessibility scaling so
/// layouts stay consistent across devices.
MediaQueryData scaledMediaQuery(BuildContext context) {
  final mq = MediaQuery.of(context);
  final widthScale = responsiveScale(context);
  final systemScale = mq.textScaler.scale(1);
  final effectiveScale = widthScale * systemScale.clamp(0.92, 1.08);

  return mq.copyWith(textScaler: TextScaler.linear(effectiveScale));
}

extension ResponsiveContext on BuildContext {
  double get scale => responsiveScale(this);

  double rs(double value) => responsiveSize(this, value);

  double rf(double value) => responsiveFontSize(this, value);

  double get horizontalPadding => responsiveHorizontalPadding(this);

  double get scaffoldBottomPadding => responsiveScaffoldBottomPadding(this);

  double get floatingNavTotalHeight => responsiveFloatingNavTotalHeight(this);
}
