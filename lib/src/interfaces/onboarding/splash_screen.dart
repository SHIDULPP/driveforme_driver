import 'dart:developer';
import 'dart:ui';

import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:driveforme_driver/src/data/providers/screen_data_providers.dart';
import 'package:driveforme_driver/src/data/services/auth_session_service.dart';
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    log('SplashScreen initState called', name: 'SplashScreen');
    WidgetsBinding.instance.addObserver(this);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _blurAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    Future.delayed(const Duration(seconds: 3), _navigateFromSession);
  }

  Future<void> _navigateFromSession() async {
    final route = await ref.read(authSessionServiceProvider).resolveInitialRoute();
    if (!mounted) return;
    NavigationService().pushNamedAndRemoveUntil(route);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final logoSize = screenSize.responsivePadding(220);
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: kWhite,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: _blurAnimation.value,
                            sigmaY: _blurAnimation.value,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                heightFactor: 0.45,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: logoSize,
                                      height: logoSize,
                                      child: Image.asset(
                                        'assets/pngs/drive_forme_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    if (_entranceController.value > 0.5)
                                      Shimmer.fromColors(
                                        baseColor: Colors.transparent,
                                        highlightColor: Colors.white
                                            .withOpacity(0.8),
                                        period: const Duration(
                                          milliseconds: 1500,
                                        ),
                                        direction: ShimmerDirection.ltr,
                                        child: SizedBox(
                                          width: logoSize,
                                          height: logoSize,
                                          child: Image.asset(
                                            'assets/pngs/drive_forme_logo.png',
                                            fit: BoxFit.contain,
                                            color: Colors.white.withAlpha(200),
                                            colorBlendMode: BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 2),
                              // Stack(
                              //   alignment: Alignment.center,
                              //   children: [
                              //     Text(
                              //       "Connecting Malayalees\nWorldwide",
                              //       textAlign: TextAlign.center,
                              //       style: kBodyTitleL.copyWith(
                              //         color: kTextColor,
                              //         height: 1.3,
                              //       ),
                              //     ),
                              //     if (_entranceController.value > 0.5)
                              //       Shimmer.fromColors(
                              //         baseColor: Colors.transparent,
                              //         highlightColor: Colors.white.withOpacity(
                              //           0.8,
                              //         ),
                              //         period: const Duration(
                              //           milliseconds: 1500,
                              //         ),
                              //         direction: ShimmerDirection.ltr,
                              //         child: Text(
                              //           "Connecting Malayalees\nWorldwide",
                              //           textAlign: TextAlign.center,
                              //           style: kBodyTitleL.copyWith(
                              //             color: Colors.white.withAlpha(200),
                              //             height: 1.3,
                              //           ),
                              //         ),
                              //       ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
