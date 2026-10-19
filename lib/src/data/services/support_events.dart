import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:DriveFormeDriver/src/data/services/secure_storage_service.dart';

// A separate connection keeps support listeners independent of trip tracking.
// Riverpod releases it when the last support screen closes.
final supportEventsProvider = StreamProvider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  final events = StreamController<Map<String, dynamic>>();
  io.Socket? socket;
  var disposed = false;
  final storage = ref.read(secureStorageServiceProvider);
  ref.onDispose(() {
    disposed = true;
    socket?.dispose();
    events.close();
  });
  Future<void> connect() async {
    final userId = await storage.getUserId();
    final token = await storage.getAuthToken();
    if (disposed || userId == null || token == null) return;
    final base = Uri.parse(dotenv.env['BASE_URL'] ?? '');
    socket = io.io(
      base.origin,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );
    socket!.onConnect((_) {
      socket!.emit('join_user_room', {'userId': userId});
      if (!disposed) events.add({'reconnected': true});
    });
    for (final event in ['support_message', 'support_ticket_updated']) {
      socket!.on(event, (data) {
        if (!disposed && data is Map) {
          events.add(Map<String, dynamic>.from(data));
        }
      });
    }
    socket!.connect();
  }

  connect().catchError((Object error, StackTrace stack) {
    if (!disposed) events.addError(error, stack);
  });
  return events.stream;
});
