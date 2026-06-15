import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/interfaces/animations/index.dart' as anim;
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kActionButtonBg = Color(0xFFE7E7F1);
const _kImageBorder = Color(0xFFD4C4A8);
const _kImageBg = Color(0xFFF8F8FA);
const _kContinueDisabled = Color(0xFFD4D8E8);

class DocumentsUploadPage extends ConsumerStatefulWidget {
  const DocumentsUploadPage({super.key});

  @override
  ConsumerState<DocumentsUploadPage> createState() =>
      _DocumentsUploadPageState();
}

class _DocumentsUploadPageState extends ConsumerState<DocumentsUploadPage> {
  String? _aadhaarImageUrl;
  String? _licenseImageUrl;
  String? _livePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  Future<void> _loadExistingDocuments() async {
    final user = await ref.read(userProvider.future);
    if (!mounted || user == null) return;

    final verification = user.driverVerification;
    setState(() {
      if (verification.aadhaarImageUrl.isNotEmpty) {
        _aadhaarImageUrl = verification.aadhaarImageUrl;
      }
      if (verification.drivingLicenseImageUrl.isNotEmpty) {
        _licenseImageUrl = verification.drivingLicenseImageUrl;
      }
      if (verification.livePhotoUrl.isNotEmpty) {
        _livePhotoUrl = verification.livePhotoUrl;
      }
    });
  }

  bool get _aadhaarUploaded =>
      _aadhaarImageUrl != null && _aadhaarImageUrl!.isNotEmpty;
  bool get _licenseUploaded =>
      _licenseImageUrl != null && _licenseImageUrl!.isNotEmpty;
  bool get _livePhotoCaptured =>
      _livePhotoUrl != null && _livePhotoUrl!.isNotEmpty;

  bool get _canContinue =>
      _aadhaarUploaded && _licenseUploaded && _livePhotoCaptured;

  Future<void> _submitDocuments() async {
    if (!_canContinue) return;

    ref.read(loadingProvider.notifier).startLoading();

    try {
      final response = await ref.read(onboardingApiProvider).submitDriverIdentity(
        aadhaarImageUrl: _aadhaarImageUrl!,
        drivingLicenseImageUrl: _licenseImageUrl!,
        livePhotoUrl: _livePhotoUrl!,
      );

      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Failed to submit documents');
        return;
      }

      ref.invalidate(userProvider);
      NavigationService().pushNamedAndRemoveUntil('applicationUnderReview');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      child: const AppBackButton(),
                    ),
                    const SizedBox(height: 28),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 80,
                      child: Text(
                        'Verify Your Identity',
                        style: kStyle(
                          kRegular,
                          kSize30,
                          color: kTextColor,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 120,
                      child: Text(
                        'Upload required documents to start driving',
                        style: kStyle(
                          kRegular,
                          kSize14,
                          color: kSecondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 180,
                      child: _DocumentUploadCard(
                        imagePath: 'assets/pngs/aadhar_image.png',
                        title: 'Aadhaar',
                        description: 'Government ID proof',
                        isUploaded: _aadhaarUploaded,
                        actionLabel:
                            _aadhaarUploaded ? 'Uploaded' : 'Tap to Upload',
                        actionIcon: _aadhaarUploaded
                            ? Icons.check_circle_outline
                            : Icons.file_upload_outlined,
                        onActionTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            'aadhaarUpload',
                          );
                          if (result is DocumentUploadResult && mounted) {
                            setState(() => _aadhaarImageUrl = result.imageUrl);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 260,
                      child: _DocumentUploadCard(
                        imagePath: 'assets/pngs/drivin_license_image.png',
                        title: 'Driving License',
                        description: 'Required for driver verification',
                        isUploaded: _licenseUploaded,
                        actionLabel:
                            _licenseUploaded ? 'Uploaded' : 'Tap to Upload',
                        actionIcon: _licenseUploaded
                            ? Icons.check_circle_outline
                            : Icons.file_upload_outlined,
                        onActionTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            'drivingLicenseUpload',
                          );
                          if (result is DocumentUploadResult && mounted) {
                            setState(() => _licenseImageUrl = result.imageUrl);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 340,
                      child: _DocumentUploadCard(
                        imagePath: 'assets/pngs/live_photo_image.png',
                        title: 'Live Photo',
                        description: 'Capture a real-time photo',
                        isUploaded: _livePhotoCaptured,
                        actionLabel: _livePhotoCaptured
                            ? 'Captured'
                            : 'Capture Photo',
                        actionIcon: _livePhotoCaptured
                            ? Icons.check_circle_outline
                            : Icons.camera_alt_outlined,
                        onActionTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            'selfieScreen',
                          );
                          if (result is DocumentUploadResult && mounted) {
                            setState(() => _livePhotoUrl = result.imageUrl);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 420,
                child: primaryButton(
                  label: 'Continue',
                  buttonHeight: 56,
                  fontSize: kSize16,
                  buttonColor: _canContinue ? kBrandBlue : _kContinueDisabled,
                  labelColor: kWhite,
                  isLoading: isLoading,
                  onPressed: _canContinue && !isLoading ? _submitDocuments : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  const _DocumentUploadCard({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isUploaded,
    required this.actionLabel,
    required this.actionIcon,
    required this.onActionTap,
  });

  final String imagePath;
  final String title;
  final String description;
  final bool isUploaded;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUploaded ? kActiveGreen : kCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 72,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kImageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kImageBorder, width: 1.2),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kProfileNameB),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: kCaption13R.copyWith(color: kMutedText),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isUploaded
                          ? kActiveGreen.withValues(alpha: 0.12)
                          : _kActionButtonBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          actionIcon,
                          size: 16,
                          color: isUploaded ? kActiveGreen : kBrandBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          actionLabel,
                          style: kStyle(
                            kMedium,
                            kSize13,
                            color: isUploaded ? kActiveGreen : kBrandBlue,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
