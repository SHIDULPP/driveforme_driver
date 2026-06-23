import 'package:driveforme_driver/src/data/providers/active_trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/notification_provider.dart';
import 'package:driveforme_driver/src/data/providers/trip_provider.dart';
import 'package:driveforme_driver/src/data/providers/user_provider.dart';
import 'package:driveforme_driver/src/data/providers/wallet_provider.dart';
import 'package:driveforme_driver/src/data/services/secure_storage_service.dart';
import 'package:driveforme_driver/src/data/services/trip_socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthLogoutService {
  Future<void> logout(WidgetRef ref) async {
    final socket = ref.read(tripSocketServiceProvider);
    socket.leaveDriversRoom();
    socket.leaveUserRoom();
    socket.disconnect();

    await ref.read(secureStorageServiceProvider).clearSession();
    await ref.read(secureStorageServiceProvider).clearDriverOnline();
    await ref.read(activeTripProvider.notifier).clear();

    ref.read(driverOnlineProvider.notifier).state = false;
    ref.invalidate(userProvider);
    ref.invalidate(walletProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(activeTripProvider);
  }
}

final authLogoutServiceProvider = Provider<AuthLogoutService>((ref) {
  return AuthLogoutService();
});
