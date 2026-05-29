import 'dart:async';
import 'dart:developer';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/constants/style_constans.dart';
import 'package:driveforme_driver/src/data/providers/loading_provider.dart';
import 'package:driveforme_driver/src/interfaces/animations/animated_widget_wrapper.dart'
    as anim;
import 'package:driveforme_driver/src/interfaces/components/primarybutton.dart';
import 'package:driveforme_driver/src/interfaces/onbording/registration.dart';

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
  final bool _showPhoneError = false;

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
                                return 'mobileNumberRequired';
                              }
                              // Validate that it contains only digits
                              if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
                                return 'mobileNumberDigitsOnly';
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
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(8.0),
                              //   borderSide: BorderSide(color: kBorder),
                              // ),
                              // enabledBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(8.0),
                              //   borderSide: BorderSide(color: kBorder),
                              // ),
                              // focusedBorder: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(8.0),
                              //   borderSide: const BorderSide(
                              //     color: kPrimaryColor,
                              //     width: 2.0,
                              //   ),
                              // ),
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
                              log(
                                'Phone number changed: ${phone.completeNumber}',
                                name: 'PhoneNumberScreen',
                              );
                            },
                            // flagsButtonPadding: const EdgeInsets.only(
                            //   left: 10,
                            //   right: 10.0,
                            // ),
                            showDropdownIcon: false,
                            // dropdownIcon: const Icon(
                            //   Icons.arrow_drop_down_outlined,
                            //   color: kTextColor,
                            // ),
                            // dropdownIconPosition: IconPosition.trailing,
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OTPScreen(
                                    fullPhone: '1234567890',
                                    countryCode: '+91',
                                  ),
                                ),
                              );
                            },
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
}

class OTPScreen extends ConsumerStatefulWidget {
  final String fullPhone;
  final String countryCode;
  // final String verificationId; // Not needed for backend OTP
  // final String resendToken; // Not needed for backend OTP

  const OTPScreen({
    required this.fullPhone,
    required this.countryCode,
    // this.verificationId, // Not needed for backend OTP
    // this.resendToken, // Not needed for backend OTP
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
    _otpController.dispose();
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

  // void resendCode() {
  //   final connectivityStatus = ref.read(connectivityProvider);
  //   if (connectivityStatus == NetworkStatus.offline) {
  //     SnackbarService().showSnackBar(context, 'noInternet'.tr());
  //     return;
  //   }

  //   startTimer();
  //   _resendOtp();
  // }

  // Future<void> _resendOtp() async {
  //   try {
  //     final secureStorage = ref.read(secureStorageServiceProvider);
  //     String? fcmToken;
  //     final existingFcmToken = await secureStorage.getFcmToken();
  //     if (existingFcmToken == null || existingFcmToken.isEmpty) {
  //       await getFcmToken(context, ref);
  //       fcmToken = await secureStorage.getFcmToken();
  //     } else {
  //       fcmToken = existingFcmToken;
  //     }

  //     final authLoginApi = ref.read(authLoginApiProvider);
  //     final response = await authLoginApi.Login(
  //       widget.fullPhone,
  //       fcmToken ?? '',
  //     );

  //     if (response.success) {
  //       SnackbarService().showSnackBar(context, 'otpResentSuccess'.tr());
  //       log('OTP resent successfully', name: 'OTPScreen');
  //     } else {
  //       SnackbarService().showSnackBar(
  //         context,
  //         response.message ?? 'failedToResendOtp'.tr(),
  //       );
  //       log('Error resending OTP: ${response.message}', name: 'OTPScreen');
  //     }
  //   } catch (e) {
  //     SnackbarService().showSnackBar(context, 'Error: $e');
  //     log('Error resending OTP: $e', name: 'OTPScreen');
  //   }
  // }

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
            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                    // Title
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AppAnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      child: Text('Enter OTP', style: kHeadTitleR),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle — masked phone highlighted in blue
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
                              text: 'We have send a 4 digit OTP to ',
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

                    // 4-digit OTP — underline style, large digits
                    anim.AnimatedWidgetWrapper(
                      animationType:
                          anim.AppAnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 200,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 4,
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.scale,
                        textStyle: const TextStyle(
                          fontFamily: 'ClashGrotesk',
                          color: kTextColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          fieldHeight: 64,
                          fieldWidth: 64,
                          selectedColor: kPrimaryColor,
                          activeColor: kPrimaryColor,
                          inactiveColor: kBorder,
                          activeFillColor: Colors.transparent,
                          selectedFillColor: Colors.transparent,
                          inactiveFillColor: Colors.transparent,
                          borderWidth: 1.5,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        controller: _otpController,
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "Didn't get SMS?" + countdown / resend
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
                              onTap: startTimer,
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

            // ── Verify OTP button pinned to bottom ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AppAnimationType.fadeScaleUp,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: 400,
                child: primaryButton(
                  label: 'Verify OTP',
                  buttonHeight: 56,
                  fontSize: 16,
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pushNamed(context, 'GetStarted');
                        },
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _handleOtpVerification(
  //   BuildContext context,
  //   WidgetRef ref,
  // ) async {
  //   final connectivityStatus = ref.read(connectivityProvider);
  //   if (connectivityStatus == NetworkStatus.offline) {
  //     SnackbarService().showSnackBar(context, 'noInternet');
  //     return;
  //   }

  //   final otp = _otpController.text;

  //   if (otp.isEmpty || otp.length != 6) {
  //     SnackbarService().showSnackBar(context, 'pleaseEnterValidOtp');
  //     return;
  //   }

  //   try {
  //     ref.read(loadingProvider.notifier).startLoading();

  //     // Step 1: Verify OTP with backend API
  //     final authLoginApi = ref.read(authLoginApiProvider);

  //     // Debug: Log the request data
  //     log('Sending verifyOtp request with data:', name: 'OTPScreen');
  //     log('Phone: ${widget.fullPhone}', name: 'OTPScreen');
  //     log('OTP: $otp', name: 'OTPScreen');

  //     final response = await authLoginApi.verifyOtp(widget.fullPhone, otp);

  //     ref.read(loadingProvider.notifier).stopLoading();

  //     if (response.success && response.data != null) {
  //       final data = response.data!;
  //       log('Response data received: $data', name: 'OTPScreen');

  //       // Extract the nested data object (backend wraps response in data key)
  //       final nestedData = data['data'] as Map<String, dynamic>?;
  //       if (nestedData == null) {
  //         log('No nested data found', name: 'OTPScreen');
  //         SnackbarService().showSnackBar(context, 'invalidResponseData');
  //         return;
  //       }

  //       final token = nestedData['token'] as String?;
  //       final userData = nestedData['user'] as Map<String, dynamic>?;

  //       log(
  //         'Token extracted: ${token != null ? "YES" : "NO"}',
  //         name: 'OTPScreen',
  //       );
  //       log(
  //         'User data extracted: ${userData != null ? "YES" : "NO"}',
  //         name: 'OTPScreen',
  //       );

  //       if (token != null && userData != null) {
  //         final user = UserModel.fromJson(userData);
  //         final secureStorage = SecureStorageService();

  //         // Save bearer token to secure storage
  //         await secureStorage.saveBearerToken(token);
  //         if (user.id != null) {
  //           await secureStorage.saveUserId(user.id!);
  //         }

  //         // Store user in provider
  //         ref.read(userProvider.notifier).setUser(user);

  //         // Set user data in global variables for quick synchronous access
  //         GlobalVariables.setUserId(user.id);
  //         GlobalVariables.setUserName(user.name);
  //         GlobalVariables.setUserStatus(user.status);
  //         GlobalVariables.setGuestMode(false);

  //         log('OTP verified and login successful', name: 'OTPScreen');
  //         log(
  //           'User data set in global variables - ID: ${user.id}',
  //           name: 'OTPScreen',
  //         );

  //         // Check for Demo Account and show EULA
  //         if (context.mounted) {
  //           final isDemo = await secureStorage.isDemoAccount();
  //           if (isDemo) {
  //             final agreed = await showDialog<bool>(
  //               context: context,
  //               barrierDismissible: false,
  //               builder: (context) => const EulaDialog(),
  //             );

  //             if (agreed != true) {
  //               return; // Stop execution if not agreed (should exit app from dialog)
  //             }
  //           }
  //         }

  //         if (context.mounted) {
  //           // Navigate based on user status from API response, removing all previous routes
  //           final userStatus = userData['status'] as String?;

  //           if (user.referralDecisionTaken == true) {
  //             if (userStatus == 'active') {
  //               Navigator.of(
  //                 context,
  //               ).pushNamedAndRemoveUntil('navbar', (route) => false);
  //             } else {
  //               String routeName;
  //               switch (userStatus) {
  //                 case 'inactive':
  //                   routeName = 'registration';
  //                   break;
  //                 case 'pending':
  //                   routeName = 'requestSent';
  //                   break;
  //                 case 'rejected':
  //                   routeName = 'requestRejected';
  //                   break;
  //                 case 'suspended':
  //                   routeName = 'accountSuspended';
  //                   break;
  //                 default:
  //                   routeName = 'navbar';
  //               }
  //               Navigator.of(
  //                 context,
  //               ).pushNamedAndRemoveUntil(routeName, (route) => false);
  //             }
  //           } else {
  //             Navigator.of(
  //               context,
  //             ).pushNamedAndRemoveUntil('addReferral', (route) => false);
  //           }
  //         }
  //       } else {
  //         SnackbarService().showSnackBar(context, 'invalidResponseData');
  //       }
  //     } else {
  //       SnackbarService().showSnackBar(
  //         context,
  //         response.message ?? 'failedToSendOTP',
  //       );
  //     }
  //   } catch (e) {
  //     ref.read(loadingProvider.notifier).stopLoading();
  //     SnackbarService().showSnackBar(context, 'Error: $e');
  //     log('Error verifying OTP: $e', name: 'OTPScreen');
  //   }
  // }
}
