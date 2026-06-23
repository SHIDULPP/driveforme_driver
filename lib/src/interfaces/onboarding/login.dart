import 'dart:async';
import 'dart:developer';

import 'package:driveforme_driver/src/data/apis/auth_api.dart';
import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/models/api_response.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/utils/auth_navigation.dart';
import 'package:driveforme_driver/src/interfaces/animations/animated_widget_wrapper.dart'
    as anim;
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart'
    show PinCodeTextField, PinTheme, PinCodeFieldShape, AnimationType
// ignore: library_prefixes
;
import 'package:pin_code_fields/pin_code_fields.dart';

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
  String _fullPhoneNumber = '';

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
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                child: Text('Verify Your Number', style: kHeadTitleR),
              ),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AppAnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 200,
                          child: IntlPhoneField(
                            focusNode: _phoneFocusNode,
                            validator: (phone) {
                              if (!_showPhoneError) {
                                return null;
                              }
                              if (phone == null || phone.number.isEmpty) {
                                return 'Mobile number is required';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
                                return 'Mobile number must contain only digits';
                              }
                              return null;
                            },
                            style: kSubHeadingR.copyWith(
                              fontSize: 25,
                              color: kGreyDark,
                            ),
                            controller: _mobileController,
                            disableLengthCheck: true,
                            showCountryFlag: false,
                            cursorColor: kBlack,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: kBackgroundColor,
                              hintText: 'Mobile Number',
                              hintStyle: kSubHeadingR.copyWith(
                                fontSize: 25,
                                color: kGreyDark,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 10.0,
                              ),
                            ),
                            onCountryChanged: (value) {
                              ref.read(countryCodeProvider.notifier).state =
                                  value.dialCode;
                            },
                            initialCountryCode: 'IN',
                            onChanged: (phone) {
                              _fullPhoneNumber = phone.completeNumber;
                              log(
                                'Phone number changed: ${phone.completeNumber}',
                                name: 'PhoneNumberScreen',
                              );
                            },
                            showDropdownIcon: false,
                            dropdownTextStyle: const TextStyle(
                              color: kTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
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
                    child: Column(
                      children: [
                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: primaryButton(
                            label: 'Get OTP',
                            onPressed: isLoading ? null : _requestOtp,
                            isLoading: isLoading,
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

    final phoneNumber = _fullPhoneNumber.isNotEmpty
        ? _fullPhoneNumber
        : '+${ref.read(countryCodeProvider)}$digits';

    ref.read(loadingProvider.notifier).startLoading();

    try {
      final response = await ref.read(authApiProvider).requestOtp(phoneNumber);
      if (!mounted) return;

      if (!response.success) {
        _showMessage(response.message ?? 'Failed to send OTP');
        return;
      }

      final data = nestedData(response.data);
      final otpCode = data?['otpCode'] as String?;
      if (otpCode != null) {
        log('Dev OTP: $otpCode', name: 'PhoneNumberScreen');
      }

      final countryCode = ref.read(countryCodeProvider) ?? '91';

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
                      child: Text('Enter OTP', style: kHeadTitleR),
                    ),
                    const SizedBox(height: 12),

                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 100,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: kSecondaryTextColor,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'We have sent a 6 digit OTP to ',
                            ),
                            TextSpan(
                              text: _maskedPhone(),
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
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
                              color: kTextColor,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              fieldHeight: 56,
                              fieldWidth: fieldWidth,
                              selectedColor: kPrimaryColor,
                              activeColor: kPrimaryColor,
                              inactiveColor: kBorder,
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
                            onChanged: (value) {},
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
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Didi'nt get SMS?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'ClashGrotesk',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (_isButtonDisabled)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'ClashGrotesk',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: kSecondaryTextColor,
                                ),
                                children: [
                                  const TextSpan(text: 'Get a new OTP in '),
                                  TextSpan(
                                    text:
                                        '00:${_start.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _resendOtp,
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontFamily: 'ClashGrotesk',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
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
                  buttonHeight: MediaQuery.of(context).size.height * 0.065,
                  fontSize: 16,
                  onPressed: isLoading ? null : _verifyOtp,
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

      final otpCode = nestedData(response.data)?['otpCode'] as String?;
      if (otpCode != null) {
        log('Dev OTP: $otpCode', name: 'OTPScreen');
      }

      _showMessage('OTP sent again');
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
      final onboardingStatus = data?['onboardingStatus'] as String?;

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

      final route = routeForOnboardingStatus(
        onboardingStatus ?? 'profile_pending',
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
