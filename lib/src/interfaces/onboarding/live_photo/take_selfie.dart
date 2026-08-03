import 'package:camera/camera.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class TakeSelfiePage extends ConsumerStatefulWidget {
  const TakeSelfiePage({super.key});

  @override
  ConsumerState<TakeSelfiePage> createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends ConsumerState<TakeSelfiePage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isUploading = false;
  String? _cameraError;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() => _cameraError = 'Camera permission is required.');
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() => _cameraError = 'No camera found on this device.');
      }
      return;
    }

    // Prefer front camera for selfie
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraError = null;
      });
    } catch (e) {
      controller.dispose();
      if (mounted) {
        setState(() => _cameraError = 'Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _captureAndUpload() async {
    final controller = _cameraController;
    if (_isUploading || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() => _isUploading = true);
    ref.read(loadingProvider.notifier).startLoading();

    try {
      // Capture the photo
      final XFile imageFile = await controller.takePicture();
      if (!mounted) return;

      // Upload the captured image
      final imageUrl = await ref
          .read(uploadServiceProvider)
          .uploadImageFile(
            imageFile.path,
            folder: 'driver-documents/live-photo',
          );

      if (!mounted) return;

      Navigator.pop(
        context,
        DocumentUploadResult(
          imageUrl: imageUrl,
          localPath: imageFile.path,
        ),
      );
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
                // ── Live Camera Preview ──────────────────────────────
                if (_isCameraReady && _cameraController != null)
                  _CameraPreviewFill(controller: _cameraController!)
                else if (_cameraError != null)
                  _CameraErrorView(message: _cameraError!)
                else
                  const _CameraLoadingView(),

                // ── Dark overlay with oval cutout ─────────────────────
                CustomPaint(
                  size: size,
                  painter: _OvalCutoutOverlayPainter(ovalRect: ovalRect),
                ),

                // ── UI Controls ───────────────────────────────────────
                SafeArea(
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        top: 4,
                        left: 20,
                        child: AppBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),

                      // Uploading indicator
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

                      // Instruction text below oval
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
                                  : 'Make sure your face is inside the frame and capture a photo.',
                              textAlign: TextAlign.center,
                              style: kCaption14R.copyWith(
                                color: kWhite.withValues(alpha: 0.92),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Shutter button
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 28,
                        child: Center(
                          child: _ShutterButton(
                            isDisabled: _isUploading || !_isCameraReady,
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

// ── Camera preview scaled to fill the screen ─────────────────────────────────

class _CameraPreviewFill extends StatelessWidget {
  const _CameraPreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// ── Loading state ─────────────────────────────────────────────────────────────

class _CameraLoadingView extends StatelessWidget {
  const _CameraLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: kWhite),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kWhite, fontSize: 16),
        ),
      ),
    );
  }
}

// ── Oval cutout overlay with visible border frame ─────────────────────────────

class _OvalCutoutOverlayPainter extends CustomPainter {
  _OvalCutoutOverlayPainter({required this.ovalRect});

  final Rect ovalRect;

  @override
  void paint(Canvas canvas, Size size) {
    // Dark overlay with oval cutout
    final overlay = Paint()..color = kBlack.withValues(alpha: 0.55);
    final screen = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addOval(ovalRect);
    final path = Path.combine(PathOperation.difference, screen, cutout);
    canvas.drawPath(path, overlay);

    // Solid white border frame around the oval
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawOval(ovalRect, borderPaint);

    // Soft outer glow ring for visual depth
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawOval(ovalRect.inflate(5), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _OvalCutoutOverlayPainter oldDelegate) {
    return oldDelegate.ovalRect != ovalRect;
  }
}

// ── Shutter button ────────────────────────────────────────────────────────────

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
