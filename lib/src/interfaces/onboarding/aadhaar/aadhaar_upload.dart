import 'dart:io';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/data/utils/document_upload_helper.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AadhaarUploadPage extends ConsumerStatefulWidget {
  const AadhaarUploadPage({super.key});

  @override
  ConsumerState<AadhaarUploadPage> createState() => _AadhaarUploadPageState();
}

class _AadhaarUploadPageState extends ConsumerState<AadhaarUploadPage> {
  final _aadhaarController = TextEditingController();

  String? _imageUrl;
  String? _localImagePath;
  bool _isUploading = false;

  bool get _hasImage => _imageUrl != null && _imageUrl!.isNotEmpty;

  bool get _canSubmit =>
      _hasImage &&
      _aadhaarController.text.replaceAll(RegExp(r'\D'), '').length == 12;

  @override
  void initState() {
    super.initState();
    _aadhaarController.addListener(_onAadhaarChanged);
  }

  @override
  void dispose() {
    _aadhaarController.removeListener(_onAadhaarChanged);
    _aadhaarController.dispose();
    super.dispose();
  }

  void _onAadhaarChanged() => setState(() {});

  void _clearImage() {
    setState(() {
      _imageUrl = null;
      _localImagePath = null;
    });
  }

  Future<void> _pickAndUpload({ImageSource? source}) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    ref.read(loadingProvider.notifier).startLoading();

    try {
      final result = await pickAndUploadDocumentImage(
        context: context,
        uploadService: ref.read(uploadServiceProvider),
        source: source,
        folder: 'driver-documents/aadhaar',
      );
      if (!mounted || result == null) return;

      setState(() {
        _imageUrl = result.imageUrl;
        _localImagePath = result.localPath;
      });
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                    const AppBackButton(),
                    const SizedBox(height: 28),
                    Text(
                      'Upload Aadhaar card',
                      style: kStyle(
                        kMedium,
                        kSize30,
                        color: kTextColor,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure all details are clearly visible',
                      style: kCaption14R.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _hasImage
                        ? _AadhaarPreviewCard(
                            previewFile: localPreviewFile(_localImagePath),
                            onRetake: _clearImage,
                            onReplace: () => _pickAndUpload(),
                          )
                        : _AadhaarUploadCard(
                            isUploading: _isUploading,
                            onTakePhoto: () =>
                                _pickAndUpload(source: ImageSource.camera),
                            onUploadFromGallery: () =>
                                _pickAndUpload(source: ImageSource.gallery),
                            onTapUploadArea: () => _pickAndUpload(),
                          ),
                    const SizedBox(height: 24),
                    Text('Aadhaar Number', style: kTripSubSectionSB),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'eg: 3755 1929 0862',
                      controller: _aadhaarController,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: primaryButton(
                label: 'Add Aadhaar',
                buttonHeight: 56,
                fontSize: kSize16,
                buttonColor: _canSubmit ? kBrandBlue : kTripCloseBtnBg,
                labelColor: kWhite,
                isLoading: isLoading,
                onPressed: _canSubmit && !isLoading
                    ? () {
                        Navigator.pop(
                          context,
                          DocumentUploadResult(
                            imageUrl: _imageUrl!,
                            localPath: _localImagePath ?? '',
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AadhaarUploadCard extends StatelessWidget {
  const _AadhaarUploadCard({
    required this.isUploading,
    required this.onTakePhoto,
    required this.onUploadFromGallery,
    required this.onTapUploadArea,
  });

  final bool isUploading;
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadFromGallery;
  final VoidCallback onTapUploadArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSosScreenBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: isUploading ? null : onTapUploadArea,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCardBorder),
              ),
              child: Column(
                children: [
                  if (isUploading)
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else
                    Icon(Icons.image_outlined, size: 40, color: kBrandBlue),
                  const SizedBox(height: 14),
                  Text(
                    isUploading
                        ? 'Uploading image...'
                        : 'Tap to upload your image',
                    textAlign: TextAlign.center,
                    style: kCaption14B,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats JPEG, PNG, upto 50MB',
                    textAlign: TextAlign.center,
                    style: kCaption12R.copyWith(color: kMutedText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _UploadActionButton(
                  label: 'Take Photo',
                  isPrimary: true,
                  onTap: isUploading ? null : onTakePhoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadActionButton(
                  label: 'Upload from Gallery',
                  isPrimary: false,
                  onTap: isUploading ? null : onUploadFromGallery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AadhaarPreviewCard extends StatelessWidget {
  const _AadhaarPreviewCard({
    required this.previewFile,
    required this.onRetake,
    required this.onReplace,
  });

  final File? previewFile;
  final VoidCallback onRetake;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSosScreenBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kActiveGreen, width: 1.5),
            ),
            child: previewFile != null
                ? Image.file(previewFile!, fit: BoxFit.contain)
                : Image.asset(
                    'assets/pngs/aadhar_image.png',
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _UploadActionButton(
                  label: 'Retake Photo',
                  isPrimary: false,
                  onTap: onRetake,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadActionButton(
                  label: 'Replace',
                  isPrimary: false,
                  onTap: onReplace,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadActionButton extends StatelessWidget {
  const _UploadActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? kBrandBlue : kTripDestIconBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: kStyle(
                kMedium,
                kSize13,
                color: isPrimary ? kWhite : kBrandBlue,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
