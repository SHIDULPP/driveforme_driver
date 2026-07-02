import 'package:driveforme_driver/src/data/providers/screen_data_providers.dart';
import 'package:driveforme_driver/src/data/route/route.dart' as router;
import 'package:driveforme_driver/src/data/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: 'Splash',
      title: 'Drive For Me',
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
        return ScreenSizeScope(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
