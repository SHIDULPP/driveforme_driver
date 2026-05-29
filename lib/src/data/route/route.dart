import 'package:driveforme_driver/src/interfaces/onbording/get_started.dart';
import 'package:driveforme_driver/src/interfaces/onbording/login.dart';
import 'package:driveforme_driver/src/interfaces/onbording/registration.dart';
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
    // case 'navbar':
    //   page = const NavBar();
    //   transitionToUse = TransitionType.fade;
    //   transitionDuration = const Duration(milliseconds: 400);
    //   break;

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
  if (transitionToUse == null) {
    return MaterialPageRoute(settings: settings, builder: (_) => page!);
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
