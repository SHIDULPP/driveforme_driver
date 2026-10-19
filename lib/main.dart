import 'package:DriveFormeDriver/firebase_options.dart';
import 'package:DriveFormeDriver/src/data/constants/global_variables.dart';
import 'package:DriveFormeDriver/src/data/providers/screen_data_providers.dart';
import 'package:DriveFormeDriver/src/data/route/route.dart' as router;
import 'package:DriveFormeDriver/src/data/services/navigation_services.dart';
import 'package:DriveFormeDriver/src/data/services/notification_token_service.dart';
import 'package:DriveFormeDriver/src/data/services/secure_storage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await EasyLocalization.ensureInitialized();

  final secureStorage = SecureStorageService();
  String preferredLanguage = 'en';
  try {
    preferredLanguage = await secureStorage.getPreferredLanguage() ?? 'en';
  } catch (_) {
    preferredLanguage = 'en';
  }

  GlobalVariables.setPreferredLanguage(preferredLanguage);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ml')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(preferredLanguage),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: 'Splash',
      title: 'Drive For Me',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'ClashGrotesk',
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ScreenSizeScope(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
