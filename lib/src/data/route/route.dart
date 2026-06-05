import 'package:driveforme_driver/src/interfaces/main_pages/nav_bar.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_countdown_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_help_on_way_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/sos/sos_select_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/driver_arrived_screen.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/end_trip.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/cash_collected.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/raise_ticket.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_completed.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/otp_screen.dart';
import 'package:driveforme_driver/src/interfaces/components/trip_card.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/trip_pages/trip_details_page.dart'
    show TripDetailsPage, TripTicketInfo;
import 'package:driveforme_driver/src/interfaces/onbording/aadhaar/aadhaar_upload.dart';
import 'package:driveforme_driver/src/interfaces/onbording/driving_license/driving_license_upload.dart';
import 'package:driveforme_driver/src/interfaces/onbording/live_photo/selfie_screen.dart';
import 'package:driveforme_driver/src/interfaces/onbording/live_photo/take_selfie.dart';
import 'package:driveforme_driver/src/interfaces/onbording/application_rejected.dart';
import 'package:driveforme_driver/src/interfaces/onbording/application_under_review.dart';
import 'package:driveforme_driver/src/interfaces/onbording/documents_upload.dart';
import 'package:driveforme_driver/src/interfaces/onbording/get_started.dart';
import 'package:driveforme_driver/src/interfaces/onbording/login.dart';
import 'package:driveforme_driver/src/interfaces/onbording/registration.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_pages/documents_page.dart';
import 'package:driveforme_driver/src/interfaces/main_pages/profile_pages/personal_info.dart';
import 'package:driveforme_driver/src/interfaces/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
//router file

enum TransitionType { slideFromBottom, slideFromRight, fade, fadeScale }

PageRouteBuilder<T> createRoute<T>(
  Widget page, {
  TransitionType? transition,
  Duration duration = const Duration(milliseconds: 300),
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: _transitionsBuilderFor(transition),
  );
}

RouteTransitionsBuilder _transitionsBuilderFor(TransitionType? type) {
  switch (type) {
    case TransitionType.slideFromRight:
      return (context, animation, secondaryAnimation, child) {
        // Professional smooth right-to-left slide
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };

    case TransitionType.fade:
      return (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(opacity: curved, child: child);
      };

    case TransitionType.fadeScale:
      return (context, animation, secondaryAnimation, child) {
        // subtle scale + fade for a polished material-like entrance
        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final scaleTween = Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      };

    case TransitionType.slideFromBottom:
    default:
      return (context, animation, secondaryAnimation, child) {
        // Standard bottom-up slide (good for modal-ish pages)
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };
  }
}

Route<dynamic> generateRoute(RouteSettings? settings) {
  Widget? page;
  TransitionType? transitionToUse;
  Duration transitionDuration = const Duration(milliseconds: 300);

  if (settings?.arguments != null && settings!.arguments is Map) {
    final args = settings.arguments as Map;
    if (args['transition'] is TransitionType) {
      transitionToUse = args['transition'] as TransitionType;
    }
    if (args['duration'] is Duration) {
      transitionDuration = args['duration'] as Duration;
    }
  }

  switch (settings?.name) {
    case 'Splash':
      page = const SplashScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'Phone':
      page = PhoneNumberScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'GetStarted':
      page = const DriverPartnerLandingPage();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'registration':
      page = const RegistrationPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'documentsUpload':
      page = const DocumentsUploadPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'applicationUnderReview':
      page = const ApplicationUnderReviewPage();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'applicationRejected':
      page = const ApplicationRejectedPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'aadhaarUpload':
      page = const AadhaarUploadPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'drivingLicenseUpload':
      page = const DrivingLicenseUploadPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'selfieScreen':
      page = const SelfieScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'takeSelfie':
      page = const TakeSelfiePage();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 300);
      break;
    case 'navBar':
      page = const NavBar();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 300);
      break;
    case 'driverArrived':
      page = const DriverArrivedScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'tripOtp':
      page = const OtpScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'endTrip':
      page = const EndTripScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'tripCompleted':
      page = const TripCompletedScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 350);
      break;
    case 'cashCollected':
      page = const CashCollectedScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 350);
      break;
    case 'tripDetails':
      final tripDetailsArgs = settings?.arguments as Map?;
      final tripData =
          tripDetailsArgs?['trip'] as TripCardData? ??
          TripCardData.dummyUpcoming();
      final ticket = tripDetailsArgs?['ticket'] as TripTicketInfo?;
      page = TripDetailsPage(trip: tripData, ticket: ticket);
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;
    case 'sos_countdown':
      final countdownArgs = settings?.arguments as Map?;
      page = SosCountdownPage(
        locationLabel:
            countdownArgs?['locationLabel'] as String? ??
            'MG Road, Eranakulam, Kochi, GPS Active',
        initialSeconds: countdownArgs?['initialSeconds'] as int? ?? 6,
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;

    case 'sos_select':
      final sosArgs = settings?.arguments as Map?;
      page = SosSelectPage(
        locationLabel:
            sosArgs?['locationLabel'] as String? ??
            'Live location shared . MG road, Erankulam',
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;

    case 'sos_help_on_way':
      final helpArgs = settings?.arguments as Map?;
      page = SosHelpOnWayPage(
        referenceNumber:
            helpArgs?['referenceNumber'] as String? ?? 'SOS - 2014 - 9568',
        locationLine1:
            helpArgs?['locationLine1'] as String? ?? 'MG Road, Eranakulam',
        locationLine2:
            helpArgs?['locationLine2'] as String? ??
            'Kochi, Kerala, 9.9312 N, 76.2673 E',
        supportPhone: helpArgs?['supportPhone'] as String? ?? '+91 6282359916',
      );

    case 'personalInfo':
      page = const PersonalInfoPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;

    case 'documentsPage':
      page = const DocumentsPage();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;

    case 'raiseTicket':
      final ticketArgs = settings?.arguments as Map?;
      final tripId = ticketArgs?['tripId'] as String? ?? '';
      page = RaiseTicketPage(tripId: tripId);
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 400);
      break;

    default:
      if (settings?.name?.startsWith('/app') == true) {
        return PageRouteBuilder(
          opaque: false,
          settings: settings,
          pageBuilder: (context, _, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
            return const SizedBox();
          },
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center(child: Text('No path for ${settings?.name}')),
        ),
      );
  }
  return createRoute(
    page,
    transition: transitionToUse,
    duration: transitionDuration,
    settings: settings,
  );
}

extension NavigatorTransitionHelpers on NavigatorState {
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType transition = TransitionType.slideFromBottom,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return push<T>(
      createRoute(page, transition: transition, duration: duration),
    );
  }
}
