import 'dart:async';

import 'package:driveforme_driver/src/data/apis/sos_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/sos_model.dart';
import 'package:driveforme_driver/src/data/services/driver_location_service.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SosCountdownPage extends ConsumerStatefulWidget {
  final String locationLabel;
  final String sosType;
  final String? tripId;
  final String pickupAddress;
  final int initialSeconds;

  const SosCountdownPage({
    super.key,
    this.locationLabel = 'Location sharing active',
    this.sosType = 'Other Emergency',
    this.tripId,
    this.pickupAddress = '',
    this.initialSeconds = 6,
  });

  @override
  ConsumerState<SosCountdownPage> createState() => _SosCountdownPageState();
}

class _SosCountdownPageState extends ConsumerState<SosCountdownPage> {
  late int _secondsLeft;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted || _isSubmitting) return;
    if (_secondsLeft <= 1) {
      _timer?.cancel();
      _submitSos();
      return;
    }
    setState(() => _secondsLeft--);
  }

  Future<void> _submitSos() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final address = widget.pickupAddress.isNotEmpty
        ? widget.pickupAddress
        : widget.locationLabel;

    final position =
        await ref.read(driverLocationServiceProvider).getCurrentPosition();

    final response = await ref.read(sosApiProvider).createSosAlert(
          location: SosLocation(
            address: address,
            latitude: position?.latitude,
            longitude: position?.longitude,
          ),
          sosType: widget.sosType,
          tripId: widget.tripId,
        );

    if (!mounted) return;

    if (!response.success || response.data == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to send SOS alert.')),
      );
      return;
    }

    final alert = response.data!;
    final location = alert.location;
    final lat = location.latitude;
    final lng = location.longitude;
    final coordsLine = lat != null && lng != null
        ? '${lat.toStringAsFixed(4)} N, ${lng.toStringAsFixed(4)} E'
        : '';

    NavigationService().pushNamedReplacement(
      'sos_help_on_way',
      arguments: {
        'referenceNumber': alert.referenceNumber.isNotEmpty
            ? alert.referenceNumber
            : 'SOS-${alert.id.substring(0, 8)}',
        'locationLine1': location.address.isNotEmpty ? location.address : address,
        'locationLine2': coordsLine,
        'supportPhone': alert.supportPhone ?? '+91 6282359916',
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (widget.initialSeconds - _secondsLeft) / widget.initialSeconds;

    return Scaffold(
      backgroundColor: kSosScreenBg,
      body: Column(
        children: [
          Expanded(
            flex: 52,
            child: ColoredBox(
              color: kSosRed,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SosBackButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxH = constraints.maxHeight;
                            final sirenHeight = (maxH * 0.24).clamp(56.0, 88.0);
                            final timerSize = (maxH * 0.42).clamp(120.0, 150.0);
                            final titleSize = (maxH * 0.075).clamp(20.0, 26.0);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/pngs/sos_image.png',
                                  height: sirenHeight,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: maxH * 0.04),
                                Text(
                                  'Emergency SOS',
                                  textAlign: TextAlign.center,
                                  style: kStyle(
                                    kSemiBold,
                                    titleSize,
                                    color: kWhite,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: kStyle(
                                        kRegular,
                                        14,
                                        color: kWhite,
                                        height: 1.3,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text:
                                              'Calling emergency services and notifying ',
                                        ),
                                        TextSpan(
                                          text: 'Drive4me',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: maxH * 0.05),
                                SizedBox(
                                  width: timerSize,
                                  height: timerSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: CircularProgressIndicator(
                                          value: 1 - progress,
                                          strokeWidth: 4.5,
                                          backgroundColor: kWhite.withValues(
                                            alpha: 0.25,
                                          ),
                                          color: kWhite,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$_secondsLeft',
                                            style: kStyle(
                                              kSemiBold,
                                              timerSize * 0.34,
                                              color: kWhite,
                                              height: 1,
                                            ),
                                          ),
                                          Text(
                                            'Seconds',
                                            style: kStyle(
                                              kRegular,
                                              15,
                                              color: kWhite,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 48,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: kSosCardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: kSosRedDark),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kSosRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: kWhite,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share your location',
                                  style: kStyle(
                                    kSemiBold,
                                    kSize15,
                                    color: kSosRedDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.locationLabel,
                                  style: kStyle(
                                    kRegular,
                                    kSize13,
                                    color: kSosRedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'WHAT HAPPENS NOW',
                    style: kStyle(
                      kSemiBold,
                      kSize12,
                      color: kMutedText,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SosWhatHappensStep(
                    step: 1,
                    text:
                        'Emergency services are notified with your GPS location.',
                  ),
                  const SizedBox(height: 14),
                  const SosWhatHappensStep(
                    step: 2,
                    text: 'Drive4me support team is alerted immediately.',
                  ),
                  const SizedBox(height: 14),
                  const SosWhatHappensStep(
                    step: 3,
                    text: 'Vehicle owner is notified of the emergency.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
