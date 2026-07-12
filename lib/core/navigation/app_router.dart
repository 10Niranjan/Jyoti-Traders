import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import features as we build them.
// For now, we will create generic placeholder screens.

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreenPlaceholder(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreenPlaceholder(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenPlaceholder(),
    ),
  ],
);

class SplashScreenPlaceholder extends StatelessWidget {
  const SplashScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically redirect to login after 2 seconds for setup testing.
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        context.go('/login');
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Proceed to Home (Simulated Login)'),
        ),
      ),
    );
  }
}

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Traders Retailer App Home Screen'),
      ),
    );
  }
}
