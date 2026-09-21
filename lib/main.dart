import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/constants/hive_keys.dart';
import 'core/navigation/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/utils/secure_hive.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/locale_controller.dart';
import 'core/theme/text_size_controller.dart';
import 'core/theme/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'data/datasources/seed/demo_activity_seeder.dart';
import 'data/datasources/seed/demo_catalog_seeder.dart';
import 'features/notifications/controllers/broadcast_ingestion_controller.dart';
import 'features/notifications/controllers/fcm_controller.dart';
import 'features/notifications/controllers/stock_alert_controller.dart';
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

  // Attests that requests reaching Firestore/Storage/Auth actually come
  // from this app binary, not a stolen API key replayed from a script —
  // the one gap security rules alone can't close. No-ops safely (just logs)
  // until a real Firebase project has App Check enabled for it.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
    );
  } catch (e) {
    debugPrint('App Check activation failed: $e');
  }

  // Must be registered before runApp, and only after Firebase.initializeApp
  // has at least been attempted — wrapped defensively since messaging isn't
  // available on every platform (e.g. desktop) or in a test environment.
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('FCM background handler registration failed: $e');
  }

  // Auto-capture uncaught exceptions in release builds. Disabled in debug so
  // local development errors don't pollute Crashlytics with noise, same
  // release-only gating Firebase's own docs recommend.
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      kReleaseMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Crashlytics setup failed: $e');
  }

  // Initialize local caching system (Hive)
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.settingsCache);
  // Encrypted at rest — this box caches bank details/GST/phone/address for
  // the signed-in user (and, in simulation mode, every simulated account).
  final userCacheBox = await openEncryptedBox(HiveBoxes.userCache);
  final catalogBox = await Hive.openBox(HiveBoxes.catalogCache);
  final ordersBox = await Hive.openBox(HiveBoxes.ordersCache);
  await Hive.openBox(HiveBoxes.cartBox);
  final notificationsBox = await Hive.openBox(HiveBoxes.notificationsCache);

  await seedDemoCatalogIfEmpty(catalogBox);
  await seedDemoRetailersIfEmpty(userCacheBox);
  await seedDemoOrdersIfEmpty(ordersBox);
  await seedDemoNotificationsIfEmpty(notificationsBox);

  runApp(const ProviderScope(child: JyotiTradersApp()));
}

class JyotiTradersApp extends ConsumerWidget {
  const JyotiTradersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched once here so push notifications initialize exactly once per
    // app lifetime, regardless of auth state (see fcmInitializerProvider).
    ref.watch(fcmInitializerProvider);
    // Same one-per-app-lifetime pattern — watches the retailer's order
    // history + live product stock and raises a local low-stock heads-up.
    ref.watch(stockAlertInitializerProvider);
    // Same pattern again — copies any admin broadcast the retailer hasn't
    // seen yet into their own notification history.
    ref.watch(broadcastIngestionProvider);
    final router = ref.watch(appRouterProvider);
    final textSize = ref.watch(textSizeProvider);

    return MaterialApp.router(
      title: 'Jyoti Traders',
      debugShowCheckedModeBanner: false,

      // Theme settings using custom app design tokens
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),

      // Language settings — null follows the device locale, same
      // null-means-system shape as themeMode above.
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Navigation router
      routerConfig: router,

      // Text size: the retailer's own Settings choice, or (Auto) the device's
      // font-scaling setting clamped to 1.3x — this app's screens use
      // fixed-height rows/cards (product cards, summary rows, the floating
      // cart bar) that were never laid out against arbitrarily large text,
      // so an unclamped scaler (up to 3.0x on some devices) would overflow
      // them. See `resolveTextScaler`.
      builder: (context, child) {
        final scaler = resolveTextScaler(
          MediaQuery.textScalerOf(context),
          textSize,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child!,
        );
      },
    );
  }
}
