import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constants/hive_keys.dart';
import 'core/navigation/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/seed/demo_catalog_seeder.dart';
import 'features/notifications/controllers/fcm_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (wrapped in try-catch to allow local developer run prior to full credentials setup)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Must be registered before runApp, and only after Firebase.initializeApp
  // has at least been attempted — wrapped defensively since messaging isn't
  // available on every platform (e.g. desktop) or in a test environment.
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('FCM background handler registration failed: $e');
  }

  // Initialize local caching system (Hive)
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.settingsCache);
  await Hive.openBox(HiveBoxes.userCache);
  final catalogBox = await Hive.openBox(HiveBoxes.catalogCache);
  await Hive.openBox(HiveBoxes.ordersCache);
  await Hive.openBox(HiveBoxes.cartBox);
  await Hive.openBox(HiveBoxes.notificationsCache);

  await seedDemoCatalogIfEmpty(catalogBox);

  runApp(
    const ProviderScope(
      child: JyotiKiranaApp(),
    ),
  );
}

class JyotiKiranaApp extends ConsumerWidget {
  const JyotiKiranaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched once here so push notifications initialize exactly once per
    // app lifetime, regardless of auth state (see fcmInitializerProvider).
    ref.watch(fcmInitializerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Jyoti Kirana',
      debugShowCheckedModeBanner: false,
      
      // Theme settings using custom app design tokens
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Responsive to OS preferences

      // Navigation router
      routerConfig: router,
    );
  }
}
