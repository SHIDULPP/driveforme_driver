import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';

/// Matches document-upload card border in onboarding flow.
const _kRejectedItemBorder = Color(0xFFD4C4A8);

class ApplicationRejectedPage extends StatelessWidget {
  const ApplicationRejectedPage({super.key});

  static const _rejectionReason =
      'The Document is blurry, text details not clearly visible.';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: kSosScreenBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/pngs/application_rejected.png',
                    width: size.width * 0.52,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Application Rejected!',
                    textAlign: TextAlign.center,
                    style: kWaitingDriverStatusBlackSB,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We couldn't verify some of your details. Please review "
                    'the reason below and upload again.',
                    textAlign: TextAlign.center,
                    style: kCaption14R.copyWith(
                      color: kSecondaryTextColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Summary',
                        style: kTripSectionTitleSB,
                      ),
                      const SizedBox(height: 16),
                      const _RejectedDocumentCard(
                        imagePath: 'assets/pngs/drivin_license_image.png',
                        title: 'Driving License',
                        reason: _rejectionReason,
                      ),
                      const SizedBox(height: 12),
                      const _RejectedDocumentCard(
                        imagePath: 'assets/pngs/aadhar_image.png',
                        title: 'Aadhaar',
                        reason: _rejectionReason,
                      ),
                      const SizedBox(height: 24),
                      primaryButton(
                        label: 'Upload Again',
                        buttonHeight: 56,
                        fontSize: kSize16,
                        buttonColor: kBrandBlue,
                        labelColor: kWhite,
                        icon: const Icon(
                          Icons.file_upload_outlined,
                          color: kWhite,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'documentsUpload');
                        },
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: kBrandBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Contact Support',
                            style: kEditProfileM.copyWith(fontSize: kSize16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedDocumentCard extends StatelessWidget {
  const _RejectedDocumentCard({
    required this.imagePath,
    required this.title,
    required this.reason,
  });

  final String imagePath;
  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kTripCreamBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kRejectedItemBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 36,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kSearchFieldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kRejectedItemBorder, width: 1),
                ),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: kProfileNameB),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kSosCardBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rejected',
                      style: kCaption12R.copyWith(
                        color: kSosRedDark,
                        fontWeight: kMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.close, size: 14, color: kSosRedDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: kCardBorder, height: 1),
          const SizedBox(height: 12),
          Text(
            reason,
            style: kCaption14R.copyWith(
              color: kTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
