import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local caching system (Hive)
  await Hive.initFlutter();
  await Hive.openBox('settings_cache');
  await Hive.openBox('user_cache');

  runApp(
    const ProviderScope(
      child: TradersRetailerApp(),
    ),
  );
}

class TradersRetailerApp extends ConsumerWidget {
  const TradersRetailerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Traders Retailer',
      debugShowCheckedModeBanner: false,
      
      // Theme settings using custom app design tokens
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Responsive to OS preferences

      // Navigation router
      routerConfig: appRouter,
    );
  }
}
