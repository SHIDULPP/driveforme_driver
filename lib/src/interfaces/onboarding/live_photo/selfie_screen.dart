import 'package:driveforme_driver/src/data/models/document_upload_result.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/interfaces/components/appbackbutton.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';

const _kExamplePhotos = [
  'assets/pngs/person1.png',
  'assets/pngs/person2.png',
  'assets/pngs/person3.png',
  'assets/pngs/person4.png',
  'assets/pngs/person5.png',
];

class SelfieScreen extends StatelessWidget {
  const SelfieScreen({super.key});

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
                      'Take a Selfie!',
                      style: kStyle(
                        kMedium,
                        kSize30,
                        color: kTextColor,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture a real-time photo for identity verification',
                      style: kCaption14R.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _ExamplePhotoGallery(),
                    const SizedBox(height: 28),
                    Text('Instructions', style: kTripSectionTitleSB),
                    const SizedBox(height: 16),
                    const _InstructionItem(
                      icon: Icons.center_focus_strong_outlined,
                      title: 'Face Clearly Visible',
                      description:
                          'Make sure your entire face is visible within the frame.',
                    ),
                    const SizedBox(height: 16),
                    const _InstructionItem(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Good Lighting',
                      description:
                          'Use proper lighting and avoid dark or backlit areas.',
                    ),
                    const SizedBox(height: 16),
                    const _InstructionItem(
                      icon: Icons.checkroom_outlined,
                      title: 'Remove Accessories',
                      description:
                          'Please remove sunglasses, hats, and marks',
                    ),
                    const SizedBox(height: 16),
                    const _InstructionItem(
                      icon: Icons.smartphone_outlined,
                      title: 'Hold Steady',
                      description:
                          'Hold your phone steady and looks straight at the camera.',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: primaryButton(
                label: 'Continue',
                buttonHeight: 56,
                fontSize: kSize16,
                buttonColor: kBrandBlue,
                labelColor: kWhite,
                onPressed: () async {
                  final captured = await Navigator.pushNamed(
                    context,
                    'takeSelfie',
                  );
                  if (captured is DocumentUploadResult && context.mounted) {
                    Navigator.pop(context, captured);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamplePhotoGallery extends StatelessWidget {
  const _ExamplePhotoGallery();

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    const photoRadius = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final photoWidth = (constraints.maxWidth - gap * 2) / 3;
        final sideInset = (constraints.maxWidth - photoWidth * 2 - gap) / 2;

        return Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: photoWidth,
                    child: _GalleryPhoto(
                      path: _kExamplePhotos[i],
                      radius: photoRadius,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                SizedBox(width: sideInset),
                SizedBox(
                  width: photoWidth,
                  child: _GalleryPhoto(
                    path: _kExamplePhotos[3],
                    radius: photoRadius,
                  ),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: photoWidth,
                  child: _GalleryPhoto(
                    path: _kExamplePhotos[4],
                    radius: photoRadius,
                  ),
                ),
                SizedBox(width: sideInset),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GalleryPhoto extends StatelessWidget {
  const _GalleryPhoto({required this.path, required this.radius});

  final String path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: kTripCreamBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: kGold),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: kCaption14B),
              const SizedBox(height: 4),
              Text(
                description,
                style: kCaption13R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
