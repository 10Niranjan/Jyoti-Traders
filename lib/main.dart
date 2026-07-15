import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
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
  
  // Initialize local caching system (Hive)
  await Hive.initFlutter();
  await Hive.openBox('settings_cache');
  await Hive.openBox('user_cache');

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
