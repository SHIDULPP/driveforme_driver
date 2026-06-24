import 'dart:async';

import 'package:driveforme_driver/src/data/apis/trip_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/trip_model.dart';
import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/utils/trip_lifecycle.dart';
import 'package:driveforme_driver/src/data/utils/trip_navigation.dart';
import 'package:driveforme_driver/src/data/utils/trip_screen_helpers.dart';
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kPickupPulse = Color(0xFFFFE8D6);
const _kOtpBoxSize = 56.0;
const _kOtpLength = 4;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    this.tripMongoId = '',
  });

  final String tripMongoId;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _pollInterval = Duration(seconds: 4);

  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  TripModel? _trip;
  Timer? _pollTimer;
  bool _navigatedAway = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
    _loadTrip();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    final trip = await fetchAndCacheTrip(ref, widget.tripMongoId);
    if (!mounted || trip == null) return;
    setState(() => _trip = trip);
  }

  void _startPolling() {
    if (widget.tripMongoId.isEmpty) return;
    _pollTripStatus();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollTripStatus());
  }

  Future<void> _pollTripStatus() async {
    if (_navigatedAway || !mounted || widget.tripMongoId.isEmpty) return;

    final trip = await fetchAndCacheTrip(ref, widget.tripMongoId);
    if (!mounted || _navigatedAway || trip == null) return;

    if (navigateIfTripLeftExpectedStatus(
      trip: trip,
      expectedStatuses: const {'driver_assigned'},
    )) {
      _navigatedAway = true;
      return;
    }

    setState(() => _trip = trip);
  }

  bool get _isOtpComplete => _otpController.text.length == _kOtpLength;

  Future<void> _startTrip() async {
    if (widget.tripMongoId.isEmpty) return;

    ref.read(loadingProvider.notifier).startLoading();
    final response = await ref.read(tripApiProvider).startTrip(
          widget.tripMongoId,
          _otpController.text,
        );
    ref.read(loadingProvider.notifier).stopLoading();

    if (!mounted) return;

    if (!response.success || response.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message ??
                'Could not start trip. Check your wallet balance and OTP.',
          ),
        ),
      );
      return;
    }

    final trip = response.data!;
    _navigatedAway = true;
    await ref.read(activeTripProvider.notifier).setActiveTrip(trip.id, trip: trip);

    final target = tripNavigationTarget(trip);
    if (target == null || !mounted) return;

    Navigator.pushReplacementNamed(
      context,
      target.route,
      arguments: target.arguments,
    );
  }

  Future<void> _handleCancel() async {
    _pollTimer?.cancel();
    _navigatedAway = true;

    final trip = await cancelTripWithDialog(
      context: context,
      ref: ref,
      tripMongoId: widget.tripMongoId,
    );
    if (!mounted) return;

    if (trip == null) {
      _navigatedAway = false;
      _startPolling();
      return;
    }

    navigateToHomeAfterActiveTripEnds();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final otp = _otpController.text;
    final customerName = trip?.customerDisplayName ?? 'Vehicle owner';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: true,
        body: trip == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                fit: StackFit.expand,
                children: [
                  const _MapLayer(),
                  const _PickupWithCarMarker(),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 16,
                    child: _MapBackButton(
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kWhite,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 20,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          24,
                          20,
                          bottomPadding + 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 24,
                              ),
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kCardBorder),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Enter OTP to Start your trip',
                                    textAlign: TextAlign.center,
                                    style: kDriverFoundOtpTitleSB,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ask $customerName for the 4-digit code',
                                    textAlign: TextAlign.center,
                                    style: kDriverFoundOtpHintR,
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => _focusNode.requestFocus(),
                                    behavior: HitTestBehavior.opaque,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            _kOtpLength,
                                            (index) {
                                              final digit = index < otp.length
                                                  ? otp[index]
                                                  : '';
                                              final isFilled = digit.isNotEmpty;
                                              final isActive = !isFilled &&
                                                  index == otp.length;

                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  left: index == 0 ? 0 : 12,
                                                ),
                                                child: _OtpDigitBox(
                                                  digit: digit,
                                                  isFilled: isFilled,
                                                  isActive: isActive,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Opacity(
                                          opacity: 0,
                                          child: SizedBox(
                                            width: _kOtpBoxSize * _kOtpLength +
                                                12 * (_kOtpLength - 1),
                                            height: _kOtpBoxSize,
                                            child: TextField(
                                              controller: _otpController,
                                              focusNode: _focusNode,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: _kOtpLength,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration:
                                                  const InputDecoration(
                                                counterText: '',
                                                border: InputBorder.none,
                                              ),
                                              style: kDriverFoundOtpDigitSB,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Only start trip after verifying OTP',
                                    textAlign: TextAlign.center,
                                    style: kDriverFoundOtpHintR,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            primaryButton(
                              label: 'Start Trip',
                              buttonHeight: 52,
                              fontSize: kSize16,
                              buttonColor: kTripCtaBlue,
                              labelColor: kWhite,
                              onPressed: _isOtpComplete ? _startTrip : null,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _handleCancel,
                              child: Text(
                                'Cancel trip',
                                style: kCaption14M.copyWith(color: kRed),
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

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/pngs/map_image.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _PickupWithCarMarker extends StatelessWidget {
  const _PickupWithCarMarker();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Positioned(
      left: size.width * 0.38,
      top: size.height * 0.32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(100, 100),
            painter: _DashedCirclePainter(
              color: kGoldAccent.withValues(alpha: 0.7),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _kPickupPulse.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.location_on, color: kRed, size: 32),
          Positioned(
            bottom: 18,
            child: Image.asset(
              'assets/pngs/car_image.png',
              width: 36,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final radius = size.width / 2 - 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace)) / radius;
      final sweep = dashWidth / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MapBackButton extends StatelessWidget {
  const _MapBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: kWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kBlack.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: kTextColor,
        ),
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.digit,
    required this.isFilled,
    required this.isActive,
  });

  final String digit;
  final bool isFilled;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final borderColor = isFilled || isActive ? kGoldAccent : kCardBorder;

    return Container(
      width: _kOtpBoxSize,
      height: _kOtpBoxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isFilled || isActive ? 1.5 : 1,
        ),
      ),
      child: Text(digit, style: kDriverFoundOtpDigitSB),
    );
  }
}
