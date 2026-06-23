import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';

const _kAvatarBg = Color(0xFFE8E8E8);
const _kAvatarIconColor = Color(0xFFB0B0B0);

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 64,
    this.borderRadius,
  });

  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;

    Widget child;
    if (hasUrl) {
      child = Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(size),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading(size);
        },
      );
    } else {
      child = _placeholder(size);
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: size, height: size, child: child),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      color: _kAvatarBg,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.5,
        color: _kAvatarIconColor,
      ),
    );
  }

  Widget _loading(double size) {
    return Container(
      color: _kAvatarBg,
      alignment: Alignment.center,
      child: SizedBox(
        width: size * 0.3,
        height: size * 0.3,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class ProfileRatingStars extends StatelessWidget {
  const ProfileRatingStars({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? 2 : 0),
          child: Icon(icon, size: size, color: kGoldAccent),
        );
      }),
    );
  }
}
