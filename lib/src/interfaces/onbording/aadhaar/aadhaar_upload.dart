import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AadhaarUploadPage extends StatefulWidget {
  const AadhaarUploadPage({super.key});

  @override
  State<AadhaarUploadPage> createState() => _AadhaarUploadPageState();
}

class _AadhaarUploadPageState extends State<AadhaarUploadPage> {
  final _aadhaarController = TextEditingController();

  bool _hasImage = false;

  bool get _canSubmit =>
      _hasImage &&
      _aadhaarController.text.replaceAll(RegExp(r'\D'), '').length == 12;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  void _setImageUploaded() {
    setState(() => _hasImage = true);
  }

  void _clearImage() {
    setState(() => _hasImage = false);
  }

  @override
  Widget build(BuildContext context) {
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
                            onRetake: _clearImage,
                            onReplace: _setImageUploaded,
                          )
                        : _AadhaarUploadCard(
                            onTakePhoto: _setImageUploaded,
                            onUploadFromGallery: _setImageUploaded,
                            onTapUploadArea: _setImageUploaded,
                          ),
                    const SizedBox(height: 24),
                    Text('Aadhaar Number', style: kTripSubSectionSB),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _aadhaarController,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [_AadhaarInputFormatter()],
                      onChanged: (_) => setState(() {}),
                      style: kStyle(
                        kMedium,
                        kSize16,
                        color: kTextColor,
                        height: 1.2,
                      ),
                      cursorColor: kBrandBlue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: kTripDestIconBg,
                        hintText: 'eg: 3755 1929 0862',
                        hintStyle: kCaption14R.copyWith(
                          color: kMutedText,
                          fontWeight: kMedium,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: kCardBorder,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: kCardBorder,
                            width: 1,
                          ),
                        ),
                      ),
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
                onPressed: _canSubmit
                    ? () => Navigator.pop(context, true)
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
    required this.onTakePhoto,
    required this.onUploadFromGallery,
    required this.onTapUploadArea,
  });

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
            onTap: onTapUploadArea,
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
                  Icon(Icons.image_outlined, size: 40, color: kBrandBlue),
                  const SizedBox(height: 14),
                  Text(
                    'Tap to upload your image',
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
                  onTap: onTakePhoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UploadActionButton(
                  label: 'Upload from Gallery',
                  isPrimary: false,
                  onTap: onUploadFromGallery,
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
  const _AadhaarPreviewCard({required this.onRetake, required this.onReplace});

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
            child: Image.asset(
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
  final VoidCallback onTap;

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

class _AadhaarInputFormatter extends TextInputFormatter {
  const _AadhaarInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
