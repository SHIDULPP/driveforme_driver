import 'package:driveforme_driver/src/data/providers/current_location_provider.dart';
import 'package:driveforme_driver/src/data/services/location_permission_service.dart';
import 'package:driveforme_driver/src/interfaces/components/location_permission_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Wraps authenticated main-app screens and manages the custom location
/// permission flow without triggering the system permission dialog on launch.
class LocationPermissionGate extends ConsumerStatefulWidget {
  const LocationPermissionGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LocationPermissionGate> createState() =>
      _LocationPermissionGateState();
}

class _LocationPermissionGateState extends ConsumerState<LocationPermissionGate>
    with WidgetsBindingObserver {
  bool _sheetVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluatePermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluatePermission();
    }
  }

  Future<void> _evaluatePermission() async {
    if (!mounted) return;

    final service = ref.read(locationPermissionServiceProvider);
    final status = await service.checkStatus();
    ref.read(locationPermissionStatusProvider.notifier).state = status;

    if (status.isFullyGranted) {
      await _dismissSheetIfVisible();
      ref.invalidate(currentLocationProvider);
      return;
    }

    if (_sheetVisible || !mounted) return;
    await _presentSheet();
  }

  Future<void> _presentSheet() async {
    _sheetVisible = true;

    await LocationPermissionBottomSheet.show(
      context,
      onEnableLocation: () async {
        final service = ref.read(locationPermissionServiceProvider);
        final current = ref.read(locationPermissionStatusProvider);

        // Location services off → device location settings.
        if (current != null && !current.isServiceEnabled) {
          await Geolocator.openLocationSettings();
          return;
        }

        // Soft deny → show the OS permission dialog first.
        if (current == null ||
            current.accessState == LocationAccessState.denied) {
          final result = await service.requestPermission();
          ref.read(locationPermissionStatusProvider.notifier).state = result;

          if (result.isFullyGranted) {
            await _dismissSheetIfVisible();
            ref.invalidate(currentLocationProvider);
            return;
          }

          // Permanently denied after the prompt → open app settings.
          if (result.accessState == LocationAccessState.permanentlyDenied) {
            await service.openSettings();
          }
          return;
        }

        // Permanently denied → app settings is the only recovery path.
        await service.openSettings();
      },
      onNotNow: () {
        _sheetVisible = false;
      },
      onClose: () {
        _sheetVisible = false;
      },
    );

    if (mounted) {
      _sheetVisible = false;
    }
  }

  Future<void> _dismissSheetIfVisible() async {
    if (!_sheetVisible || !mounted) return;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _sheetVisible = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
