import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kPreviewAsset = 'assets/pngs/take_selfie_example.png';

class TakeSelfiePage extends StatelessWidget {
  const TakeSelfiePage({super.key});

  static Rect _ovalRect(Size size) {
    final ovalWidth = size.width * 0.78;
    final ovalHeight = size.height * 0.46;
    return Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.37),
      width: ovalWidth,
      height: ovalHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBlack,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final ovalRect = _ovalRect(size);

            return Stack(
              fit: StackFit.expand,
              children: [
                _DimmedPreviewBackground(),
                Positioned.fromRect(
                  rect: ovalRect,
                  child: ClipOval(
                    child: Image.asset(
                      _kPreviewAsset,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.15),
                    ),
                  ),
                ),
                CustomPaint(
                  size: size,
                  painter: _OvalCutoutOverlayPainter(ovalRect: ovalRect),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        left: 20,
                        child: _CameraBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: kActiveGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: kWhite,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 28,
                        right: 28,
                        top: ovalRect.bottom + 28,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Align your face in the middle',
                              textAlign: TextAlign.center,
                              style: kStyle(
                                kSemiBold,
                                kSize22,
                                color: kWhite,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Make sure your photo is inside the box and capture a photo.',
                              textAlign: TextAlign.center,
                              style: kCaption14R.copyWith(
                                color: kWhite.withValues(alpha: 0.92),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 28,
                        child: Center(
                          child: _ShutterButton(
                            onTap: () => Navigator.pop(context, true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DimmedPreviewBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        kBlack.withValues(alpha: 0.45),
        BlendMode.darken,
      ),
      child: Image.asset(
        _kPreviewAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class _OvalCutoutOverlayPainter extends CustomPainter {
  _OvalCutoutOverlayPainter({required this.ovalRect});

  final Rect ovalRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()..color = kBlack.withValues(alpha: 0.42);
    final screen = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addOval(ovalRect);
    final path = Path.combine(PathOperation.difference, screen, cutout);
    canvas.drawPath(path, overlay);
  }

  @override
  bool shouldRepaint(covariant _OvalCutoutOverlayPainter oldDelegate) {
    return oldDelegate.ovalRect != ovalRect;
  }
}

class _CameraBackButton extends StatelessWidget {
  const _CameraBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFE7E7F1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: kTextColor,
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kWhite, width: 3),
        ),
        padding: const EdgeInsets.all(7),
        child: Container(
          decoration: const BoxDecoration(
            color: kWhite,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
