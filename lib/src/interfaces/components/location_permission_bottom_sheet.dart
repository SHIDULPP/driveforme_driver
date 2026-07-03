import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/utils/responsive.dart';
import 'package:flutter/material.dart';

const _kSheetBlue = Color(0xFF1E5D94);
const _kBodyGray = Color(0xFF666666);

/// Layout tuned to the 375px-wide Figma reference.
class _SheetMetrics {
  static double horizontalMargin(BuildContext context) => context.rs(24);

  static double bottomMargin(BuildContext context) => context.rs(24);

  static double cornerRadius(BuildContext context) => context.rs(32);

  static double illustrationSize(BuildContext context) => context.rs(118);

  static double illustrationOverflow(BuildContext context) => context.rs(50);

  static double contentPaddingH(BuildContext context) => context.rs(28);

  static double contentPaddingBottom(BuildContext context) => context.rs(22);

  static double titleBodyGap(BuildContext context) => context.rs(12);

  static double bodyButtonGap(BuildContext context) => context.rs(22);

  static double buttonHeight(BuildContext context) => context.rs(52);

  static double notNowGap(BuildContext context) => context.rs(6);
}

class LocationPermissionBottomSheet extends StatelessWidget {
  const LocationPermissionBottomSheet({
    super.key,
    required this.onEnableLocation,
    this.onNotNow,
    this.onClose,
  });

  final VoidCallback onEnableLocation;
  final VoidCallback? onNotNow;
  final VoidCallback? onClose;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onEnableLocation,
    VoidCallback? onNotNow,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Location permission',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: _SheetMetrics.horizontalMargin(dialogContext),
                  right: _SheetMetrics.horizontalMargin(dialogContext),
                  bottom: _SheetMetrics.bottomMargin(dialogContext) +
                      MediaQuery.paddingOf(dialogContext).bottom,
                  top: _SheetMetrics.illustrationOverflow(dialogContext),
                ),
                child: LocationPermissionBottomSheet(
                  onEnableLocation: onEnableLocation,
                  onNotNow: onNotNow == null
                      ? null
                      : () {
                          onNotNow();
                          Navigator.of(dialogContext).pop();
                        },
                  onClose: onClose == null
                      ? null
                      : () {
                          onClose();
                          Navigator.of(dialogContext).pop();
                        },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final illustrationSize = _SheetMetrics.illustrationSize(context);
    final illustrationOverflow = _SheetMetrics.illustrationOverflow(context);
    final cornerRadius = _SheetMetrics.cornerRadius(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cornerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: context.rs(20),
                  offset: Offset(0, context.rs(6)),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _SheetMetrics.contentPaddingH(context),
                illustrationOverflow + context.rs(4),
                _SheetMetrics.contentPaddingH(context),
                _SheetMetrics.contentPaddingBottom(context),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SheetTitle(),
                  SizedBox(height: _SheetMetrics.titleBodyGap(context)),
                  Text(
                    'We use your location to share your position with '
                    'passengers and receive nearby trip requests.',
                    textAlign: TextAlign.center,
                    style: kStyle(
                      kRegular,
                      kSize15,
                      color: _kBodyGray,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: _SheetMetrics.bodyButtonGap(context)),
                  SizedBox(
                    width: double.infinity,
                    height: _SheetMetrics.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed: onEnableLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kSheetBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            _SheetMetrics.buttonHeight(context) / 2,
                          ),
                        ),
                      ),
                      child: Text(
                        'Enable Location',
                        style: kStyle(
                          kSemiBold,
                          kSize17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (onNotNow != null) ...[
                    SizedBox(height: _SheetMetrics.notNowGap(context)),
                    TextButton(
                      onPressed: onNotNow,
                      style: TextButton.styleFrom(
                        foregroundColor: _kBodyGray,
                        padding: EdgeInsets.symmetric(
                          vertical: context.rs(6),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Not Now',
                        style: kStyle(
                          kMedium,
                          kSize15,
                          color: _kBodyGray,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: -illustrationOverflow,
            child: Image.asset(
              'assets/pngs/locationpermission.png',
              width: illustrationSize,
              height: illustrationSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: context.rs(12),
            right: context.rs(12),
            child: IconButton(
              onPressed: onClose ?? onNotNow,
              icon: Icon(
                Icons.close,
                size: context.rs(20),
                color: Colors.black.withValues(alpha: 0.7),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: context.rs(32),
                minHeight: context.rs(32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) {
    final blackStyle = kStyle(
      kBold,
      kSize24,
      color: Colors.black,
      height: 1.15,
    );
    final blueStyle = blackStyle.copyWith(color: _kSheetBlue);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Enable ', style: blackStyle, textAlign: TextAlign.center),
        Text('Location Access', style: blueStyle, textAlign: TextAlign.center),
      ],
    );
  }
}
