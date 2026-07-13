import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/admin_dashboard_screen.dart';
import '../constants/app_colors.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/pending-approval',
      builder: (context, state) => const PendingApprovalScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);

// Router Provider that automatically recalculates and handles redirection reactively
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.matchedLocation;
      
      // If we are still checking local token or auth status, wait on Splash
      if (authState is AuthInitial || authState is AuthLoading) {
        return location == '/' ? null : '/';
      }

      // If user is not authenticated, force Auth screen
      if (authState is Unauthenticated || authState is AuthError) {
        return location == '/login' ? null : '/login';
      }

      // If user is pending manual admin approval, restrict to Pending Screen
      if (authState is PendingApproval) {
        return location == '/pending-approval' ? null : '/pending-approval';
      }

      // If user is Admin, route to Admin Panel
      if (authState is AuthenticatedAdmin) {
        final target = (location == '/' || location == '/login' || location == '/home' || location == '/pending-approval') 
            ? '/admin' 
            : null;
        return target;
      }

      // If user is verified Customer/Retailer, route to Marketplace
      if (authState is AuthenticatedCustomer) {
        final target = (location == '/' || location == '/login' || location == '/admin' || location == '/pending-approval') 
            ? '/home' 
            : null;
        return target;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF070B19)]
                : [const Color(0xFFEFF6FF), AppColors.backgroundLight],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
              ).animate(onPlay: (controller) {
                if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;
                controller.repeat(reverse: true);
              }).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms, curve: Curves.easeInOut),
              
              const SizedBox(height: 24),
              
              Text(
                'Jyoti Kirana',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Wholesale Market Store',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              
              const SizedBox(height: 48),
              
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
