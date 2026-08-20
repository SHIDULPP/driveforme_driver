import 'dart:async';

import 'package:driveforme_driver/src/data/apis/auth_api.dart';
import 'package:driveforme_driver/src/data/apis/onboarding_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/notification_token_service.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/auth_navigation.dart';
import 'package:driveforme_driver/src/interfaces/animations/animated_widget_wrapper.dart'
    as anim;
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Figma `--drive-for-me/dark-text-color` placeholder grey used for
/// unfilled underline inputs (Verify Number, OTP).
const Color _kFieldPlaceholderGrey = Color(0xFF9E9E9E);

final countryCodeProvider = StateProvider<String?>((ref) => '91');

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  late TextEditingController _mobileController;
  late FocusNode _phoneFocusNode;
  bool _showPhoneError = false;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
    _phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                child: Text(
                  'Verify Your Number',
                  style: kHeadTitleR,
                ),
              ),
              const SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fixed dial code — kept as a read-only underline
                          // field so its baseline matches the mobile number
                          // field exactly (Figma: "+ 91" underlined blue).
                          IgnorePointer(
                            child: SizedBox(
                              width: 56,
                              child: TextFormField(
                                initialValue: '+ 91',
                                textAlign: TextAlign.center,
                                style: kLoginPhoneFieldR.copyWith(
                                  color: kDarkText,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: kBrandBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: kBrandBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: kBrandBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (!_showPhoneError) {
                                  return null;
                                }
                                final number = value?.trim() ?? '';
                                if (number.isEmpty) {
                                  return 'Mobile number is required';
                                }
                                if (!RegExp(r'^[0-9]+$').hasMatch(number)) {
                                  return 'Mobile number must contain only digits';
                                }
                                if (number.length != 10) {
                                  return 'Mobile number must be exactly 10 digits';
                                }
                                return null;
                              },
                              style: kLoginPhoneFieldR,
                              cursorColor: kBrandBlue,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Mobile Number',
                                hintStyle: kLoginPhoneFieldR,
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _kFieldPlaceholderGrey,
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kBrandBlue,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder:
                                    const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: anim.AnimatedWidgetWrapper(
                    animationType: anim.AppAnimationType.fadeScaleUp,
                    duration: anim.AnimationDuration.normal,
                    delayMilliseconds: 400,
                    child: primaryButton(
                      label: 'Get OTP',
                      onPressed:
                          (isLoading ||
                              _mobileController.text.trim().length != 10)
                          ? null
                          : _requestOtp,
                      isLoading: isLoading,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    setState(() => _showPhoneError = true);

    final digits = _mobileController.text.trim();
    if (digits.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(digits)) {
      _showMessage('Please enter a valid mobile number');
      return;
    }

    if (digits.length != 10) {
      _showMessage('Mobile number must be exactly 10 digits');
      return;
    }

    final countryCode = ref.read(countryCodeProvider) ?? '91';
    final phoneNumber = '+$countryCode$digits';

    ref.read(loadingProvider.notifier).startLoading();

    try {
      final response = await ref.read(authApiProvider).requestOtp(phoneNumber);
      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Failed to send OTP');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            fullPhone: digits,
            countryCode: '+$countryCode',
            phoneNumber: phoneNumber,
          ),
        ),
      );
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class OTPScreen extends ConsumerStatefulWidget {
  final String fullPhone;
  final String countryCode;
  final String phoneNumber;

  const OTPScreen({
    required this.fullPhone,
    required this.countryCode,
    required this.phoneNumber,
    super.key,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  Timer? _timer;
  int _start = 59;
  bool _isButtonDisabled = true;

  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String _maskedPhone() {
    final phone = widget.fullPhone;
    if (phone.length <= 3) return '${widget.countryCode}$phone';
    final visible = phone.substring(phone.length - 3);
    final masked = 'X' * (phone.length - 3);
    return '${widget.countryCode}$masked$visible';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      child: Text(
                        'Enter OTP',
                        style: kHeadTitleR,
                      ),
                    ),
                    const SizedBox(height: 16),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 100,
                      child: RichText(
                        text: TextSpan(
                          style: kLoginSubtitleR,
                          children: [
                            const TextSpan(
                              text: 'We have sent a 6 digit OTP to ',
                            ),
                            TextSpan(
                              text: _maskedPhone(),
                              style: kLoginSubtitleAccentSB,
                            ),
                            const TextSpan(
                              text: ' number and you can use to login',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 200,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const otpLength = 6;
                          const fieldGap = 12.0;
                          final fieldWidth =
                              ((constraints.maxWidth -
                                          fieldGap * (otpLength - 1)) /
                                      otpLength)
                                  .clamp(44.0, 56.0);
                          final fontSize = fieldWidth >= 52 ? 34.0 : 28.0;

                          return PinCodeTextField(
                            appContext: context,
                            length: otpLength,
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.scale,
                            textStyle: TextStyle(
                              fontFamily: 'ClashGrotesk',
                              color: kBrandBlue,
                              fontSize: fontSize,
                              fontWeight: kMedium,
                            ),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              fieldHeight: 56,
                              fieldWidth: fieldWidth,
                              selectedColor: kBrandBlue,
                              activeColor: kBrandBlue,
                              inactiveColor: _kFieldPlaceholderGrey,
                              activeFillColor: Colors.transparent,
                              selectedFillColor: Colors.transparent,
                              inactiveFillColor: Colors.transparent,
                              borderWidth: 1.5,
                            ),
                            animationDuration: const Duration(
                              milliseconds: 300,
                            ),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            controller: _otpController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onCompleted: (value) {
                              if (!isLoading) {
                                _verifyOtp();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Didn't get SMS?",
                              textAlign: TextAlign.center,
                              style: kLoginResendPromptM,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_isButtonDisabled)
                            RichText(
                              text: TextSpan(
                                style: kLoginResendPromptM,
                                children: [
                                  const TextSpan(text: 'Get a new OTP in '),
                                  TextSpan(
                                    text:
                                        '00:${_start.toString().padLeft(2, '0')}',
                                    style: kLoginResendTimerSB,
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                'Resend OTP',
                                style: kLoginResendActionSB.copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: primaryButton(
                  label: 'Verify OTP',
                  onPressed:
                      (!isLoading && _otpController.text.trim().length == 6)
                      ? _verifyOtp
                      : null,
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resendOtp() async {
    startTimer();
    ref.read(loadingProvider.notifier).startLoading();

    try {
      final response = await ref
          .read(authApiProvider)
          .requestOtp(widget.phoneNumber);
      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Failed to resend OTP');
        return;
      }

      _showMessage(response.message ?? 'OTP sent to your phone');
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage('Please enter the 6-digit OTP');
      return;
    }

    ref.read(loadingProvider.notifier).startLoading();

    try {
      final response = await ref
          .read(authApiProvider)
          .verifyOtp(phoneNumber: widget.phoneNumber, otp: otp);
      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Invalid OTP');
        return;
      }

      final data = nestedData(response.data);
      final userId = data?['userId']?.toString();
      final token = data?['token'] as String?;

      if (userId == null || userId.isEmpty) {
        _showMessage('Invalid response from server');
        return;
      }

      if (token == null || token.isEmpty) {
        _showMessage('Invalid response from server');
        return;
      }

      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveUserId(userId);
      await storage.saveAuthToken(token);
      await storage.savePhoneNumber(widget.phoneNumber);

      await ref
          .read(notificationTokenServiceProvider)
          .registerTokenIfAvailable();

      final meResponse = await ref.read(onboardingApiProvider).getMe();
      final route = meResponse.success && meResponse.data != null
          ? routeForUser(meResponse.data!)
          : routeForOnboardingStatus(
              data?['onboardingStatus'] as String? ?? 'profile_pending',
            );
      NavigationService().pushNamedAndRemoveUntil(route);
    } finally {
      ref.read(loadingProvider.notifier).stopLoading();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
