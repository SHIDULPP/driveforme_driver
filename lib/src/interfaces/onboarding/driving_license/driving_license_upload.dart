import 'dart:io';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/upload_service.dart';
import 'package:driveforme_driver/src/data/utils/document_upload_helper.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/dropdown.dart';
import 'package:driveforme_driver/src/interfaces/components/input_field.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const _kLicenseCategories = [
  'LMV (Light Motor Vehicle)',
  'MCWG (Motorcycle with Gear)',
  'MCWOG (Motorcycle without Gear)',
  'HMV (Heavy Motor Vehicle)',
  'Transport Vehicle',
];

const _kTransmissionTypes = ['Manual', 'Automatic'];

class DrivingLicenseUploadPage extends ConsumerStatefulWidget {
  const DrivingLicenseUploadPage({super.key});

  @override
  ConsumerState<DrivingLicenseUploadPage> createState() =>
      _DrivingLicenseUploadPageState();
}

class _DrivingLicenseUploadPageState
    extends ConsumerState<DrivingLicenseUploadPage> {
  final _licenseNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String? _imageUrl;
  String? _localImagePath;
  bool _isUploading = false;
  String? _licenseCategory;
  String? _transmissionType;

  bool get _hasImage => _imageUrl != null && _imageUrl!.isNotEmpty;

  bool get _canSubmit =>
      _hasImage &&
      _licenseNumberController.text.trim().isNotEmpty &&
      _licenseCategory != null &&
      _expiryDateController.text.trim().isNotEmpty &&
      _transmissionType != null;

  @override
  void initState() {
    super.initState();
    _licenseNumberController.addListener(_onFormChanged);
    _expiryDateController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _licenseNumberController.removeListener(_onFormChanged);
    _expiryDateController.removeListener(_onFormChanged);
    _licenseNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

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
        folder: 'driver-documents/license',
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLicenseCategorySheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: kBlack54,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: _LicenseCategoryBottomSheet(initialValue: _licenseCategory),
        );
      },
    );
    if (selected != null) {
      setState(() => _licenseCategory = selected);
    }
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
                      'Upload License',
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
                        ? _LicensePreviewCard(
                            previewFile: localPreviewFile(_localImagePath),
                            onRetake: _clearImage,
                            onReplace: () => _pickAndUpload(),
                          )
                        : _LicenseUploadCard(
                            isUploading: _isUploading,
                            onTakePhoto: () =>
                                _pickAndUpload(source: ImageSource.camera),
                            onUploadFromGallery: () =>
                                _pickAndUpload(source: ImageSource.gallery),
                            onTapUploadArea: () => _pickAndUpload(),
                          ),
                    const SizedBox(height: 24),
                    const _RequiredFieldLabel(label: 'License Number'),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.text,
                      hint: 'eg: 3755 1929 0862',
                      controller: _licenseNumberController,
                    ),
                    const SizedBox(height: 20),
                    const _RequiredFieldLabel(label: 'License Category'),
                    const SizedBox(height: 8),
                    _CategorySelectorField(
                      value: _licenseCategory,
                      onTap: _openLicenseCategorySheet,
                    ),
                    const SizedBox(height: 20),
                    const _RequiredFieldLabel(label: 'Expiry Date'),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.date,
                      hint: 'DD/MM/YY',
                      controller: _expiryDateController,
                      lastDate: DateTime(2040, 12, 31),
                      onDateSelected: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    const _RequiredFieldLabel(label: 'Transmission Type'),
                    const SizedBox(height: 8),
                    AnimatedDropdown<String>(
                      hint: 'Select',
                      value: _transmissionType,
                      items: _kTransmissionTypes,
                      itemLabel: (value) => value,
                      onChanged: (value) {
                        setState(() => _transmissionType = value);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: primaryButton(
                label: 'Add License',
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

class _CategorySelectorField extends StatelessWidget {
  const _CategorySelectorField({required this.value, required this.onTap});

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: kTripDestIconBg,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: kCardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? 'Select',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kStyle(
                  kMedium,
                  kSize16,
                  color: value == null ? kMutedText : kTextColor,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: kTextColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseCategoryBottomSheet extends StatefulWidget {
  const _LicenseCategoryBottomSheet({this.initialValue});

  final String? initialValue;

  @override
  State<_LicenseCategoryBottomSheet> createState() =>
      _LicenseCategoryBottomSheetState();
}

class _LicenseCategoryBottomSheetState
    extends State<_LicenseCategoryBottomSheet> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Category', style: kTripSectionTitleSB)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: kTripDestIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: kTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._kLicenseCategories.map((category) {
            final isSelected = _selected == category;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selected = category),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kTripSelectedTint : kWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kGoldAccent : kCardBorder,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: kCaption14M.copyWith(
                      color: kTextColor,
                      fontWeight: isSelected ? kSemiBold : kMedium,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          primaryButton(
            label: 'Confirm Category',
            buttonHeight: 56,
            fontSize: kSize16,
            buttonColor: kBrandBlue,
            labelColor: kWhite,
            onPressed: _selected == null
                ? null
                : () => Navigator.pop(context, _selected),
          ),
        ],
      ),
    );
  }
}

class _RequiredFieldLabel extends StatelessWidget {
  const _RequiredFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: kTripSubSectionSB,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: kRed),
          ),
        ],
      ),
    );
  }
}

class _LicenseUploadCard extends StatelessWidget {
  const _LicenseUploadCard({
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

class _LicensePreviewCard extends StatelessWidget {
  const _LicensePreviewCard({
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
                    'assets/pngs/drivin_license_image.png',
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
