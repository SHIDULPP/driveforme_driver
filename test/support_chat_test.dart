import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:DriveFormeDriver/src/data/apis/support_api.dart';
import 'package:DriveFormeDriver/src/data/models/support_models.dart';
import 'package:DriveFormeDriver/src/data/providers/api_provider.dart';
import 'package:DriveFormeDriver/src/data/services/secure_storage_service.dart';
import 'package:DriveFormeDriver/src/data/services/support_events.dart';
import 'package:DriveFormeDriver/src/interfaces/main_pages/support/support_pages.dart';

const ticketId = '507f1f77bcf86cd799439011';

class TestStorage extends SecureStorageService {
  @override
  Future<String?> getAuthToken() async => 'test-token';
}

ApiProvider transport(http.Client client) => ApiProvider(
  baseUrl: 'https://test.invalid',
  apiKey: '',
  secureStorage: TestStorage(),
  client: client,
);

class FakeSupportApi extends SupportApi {
  FakeSupportApi()
    : super(transport(MockClient((_) async => http.Response('{}', 200))));
  String status = 'pending';
  bool failSend = false;
  int reads = 0;
  int sends = 0;
  @override
  Future<SupportTicket> getTicket(String id) async => SupportTicket({
    '_id': ticketId,
    'ticketId': 'SUP-1001',
    'subject': 'Trip question',
    'description': 'Please help with my trip',
    'status': status,
    'unreadForUser': reads == 0 ? 1 : 0,
    'assignedTo': {'fullName': 'Alex'},
  });
  @override
  Future<List<SupportMessage>> messages(String id, {DateTime? before}) async =>
      [
        SupportMessage({
          '_id': 'message-1',
          'content': 'How can I help?',
          'senderType': 'admin',
          'sender': {'fullName': 'Alex'},
          'createdAt': '2026-10-19T10:00:00Z',
        }),
      ];
  @override
  Future<void> markRead(String id) async {
    reads++;
  }

  @override
  Future<SupportMessage> sendMessage(String id, String content) async {
    sends++;
    if (failSend) throw const SupportApiException('Connection failed', 503);
    return SupportMessage({
      '_id': 'message-2',
      'content': content,
      'senderType': 'user',
      'createdAt': '2026-10-19T10:01:00Z',
    });
  }
}

Future<void> openChat(
  WidgetTester tester,
  FakeSupportApi api,
  Stream<Map<String, dynamic>> events,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supportApiProvider.overrideWithValue(api),
        supportEventsProvider.overrideWith((ref) => events),
      ],
      child: const MaterialApp(home: SupportChatPage(ticketId: ticketId)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  dotenv.testLoad(fileInput: 'API_LOGGING=false');
  test(
    'API uses Mongo ID, auth, cursor and preserves closed-ticket errors',
    () async {
      final requests = <http.Request>[];
      final api = SupportApi(
        transport(
          MockClient((request) async {
            requests.add(request);
            if (request.method == 'POST') {
              return http.Response(
                jsonEncode({'message': 'The chat is closed.'}),
                409,
              );
            }
            return http.Response(jsonEncode({'data': []}), 200);
          }),
        ),
      );
      final before = DateTime.utc(2026, 10, 19);
      await api.messages(ticketId, before: before);
      expect(requests.single.url.path, '/support/tickets/$ticketId/messages');
      expect(
        requests.single.url.queryParameters['before'],
        before.toIso8601String(),
      );
      expect(requests.single.headers['Authorization'], 'Bearer test-token');
      await expectLater(
        api.sendMessage(ticketId, ' hello '),
        throwsA(
          isA<SupportApiException>().having((e) => e.statusCode, 'status', 409),
        ),
      );
      expect(jsonDecode(requests.last.body)['content'], 'hello');
    },
  );

  testWidgets('failed send retains draft; retry sends once and clears draft', (
    tester,
  ) async {
    final api = FakeSupportApi()..failSend = true;
    await openChat(tester, api, const Stream.empty());
    expect(api.reads, 1);
    await tester.enterText(find.byType(TextField), 'Please check');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Please check',
    );
    api.failSend = false;
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(api.sends, 2);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('Please check'), findsOneWidget);
  });

  testWidgets(
    'live closure disables composer and duplicate refresh keeps one message',
    (tester) async {
      final api = FakeSupportApi();
      final events = StreamController<Map<String, dynamic>>();
      await openChat(tester, api, events.stream);
      events.add({'ticketId': ticketId});
      await tester.pumpAndSettle();
      expect(find.text('How can I help?'), findsOneWidget);
      api.status = 'resolved';
      events.add({'ticketId': ticketId});
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('This ticket is closed'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      unawaited(events.close());
    },
  );

  testWidgets('already rejected ticket is read-only', (tester) async {
    await openChat(
      tester,
      FakeSupportApi()..status = 'rejected',
      const Stream.empty(),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.text('How can I help?'), findsOneWidget);
  });
}
