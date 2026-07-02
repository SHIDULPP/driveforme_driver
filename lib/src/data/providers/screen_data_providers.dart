import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final screenSizeProvider = Provider<ScreenSizeData>((ref) {
  throw UnimplementedError(
    'screenSizeProvider must be overridden with ScreenSizeScope',
  );
});

class ScreenSizeData {
  final double width;
  final double height;
  final bool isLandscape;
  final bool isPortrait;
  final bool isTablet;
  final bool isMobile;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;

  ScreenSizeData({
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.isPortrait,
    required this.isTablet,
    required this.isMobile,
    required this.padding,
    required this.viewInsets,
  });

  double get scale => (width / kDesignWidth).clamp(0.88, 1.12);

  double widthPercent(double percent) => width * (percent / 100);

  double heightPercent(double percent) => height * (percent / 100);

  double responsiveFontSize(double baseSize) => baseSize * scale;

  double responsivePadding(double basePadding) => basePadding * scale;

  double responsiveSize(double baseSize) => baseSize * scale;

  double get horizontalPadding => responsivePadding(20);

  double scaffoldBottomPadding() =>
      responsivePadding(64) + responsivePadding(16) + padding.bottom + responsivePadding(12);
}

class ScreenSizeScope extends ConsumerWidget {
  final Widget child;

  const ScreenSizeScope({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context);
    final scaled = scaledMediaQuery(context);

    return ProviderScope(
      overrides: [
        screenSizeProvider.overrideWithValue(
          ScreenSizeData(
            width: screenSize.size.width,
            height: screenSize.size.height,
            isLandscape: screenSize.orientation == Orientation.landscape,
            isPortrait: screenSize.orientation == Orientation.portrait,
            isTablet: screenSize.size.width > 600,
            isMobile: screenSize.size.width <= 600,
            padding: screenSize.padding,
            viewInsets: screenSize.viewInsets,
          ),
        ),
      ],
      child: MediaQuery(data: scaled, child: child),
    );
  }
}
