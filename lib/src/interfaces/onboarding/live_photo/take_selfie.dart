import 'dart:io';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/data/utils/document_upload_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPreviewAsset = 'assets/pngs/take_selfie_example.png';

class TakeSelfiePage extends ConsumerStatefulWidget {
  const TakeSelfiePage({super.key});

  @override
  ConsumerState<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends ConsumerState<TakeSelfiePage> {
  String? _localImagePath;
  bool _isUploading = false;

  static Rect _ovalRect(Size size) {
    final ovalWidth = size.width * 0.78;
    final ovalHeight = size.height * 0.46;
    return Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.37),
      width: ovalWidth,
      height: ovalHeight,
    );
  }

  Future<void> _captureAndUpload() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    ref.read(loadingProvider.notifier).startLoading();

    try {
      final result = await pickAndUploadDocumentImage(
        context: context,
        uploadService: ref.read(uploadServiceProvider),
        cameraOnly: true,
        folder: 'driver-documents/live-photo',
      );
      if (!mounted || result == null) return;

      Navigator.pop(context, result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewFile = localPreviewFile(_localImagePath);

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
                _DimmedPreviewBackground(previewFile: previewFile),
                Positioned.fromRect(
                  rect: ovalRect,
                  child: ClipOval(
                    child: previewFile != null
                        ? Image.file(
                            previewFile,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, -0.15),
                          )
                        : Image.asset(
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
                      if (_isUploading)
                        Positioned(
                          top: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: kWhite,
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
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
                              _isUploading
                                  ? 'Uploading your live photo...'
                                  : 'Make sure your photo is inside the box and capture a photo.',
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
                            isDisabled: _isUploading,
                            onTap: _captureAndUpload,
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
  const _DimmedPreviewBackground({required this.previewFile});

  final File? previewFile;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        kBlack.withValues(alpha: 0.45),
        BlendMode.darken,
      ),
      child: previewFile != null
          ? Image.file(
              previewFile!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Image.asset(
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
  const _ShutterButton({required this.onTap, required this.isDisabled});

  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
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
      ),
    );
  }
}
