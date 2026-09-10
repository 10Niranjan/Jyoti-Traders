import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/features/auth/screens/onboarding_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

/// Overrides just the first-launch flag so this test never touches a real
/// Hive box, mirroring `FakeLocalStorageService` in theme_controller_test.dart.
class FakeLocalStorageService extends LocalStorageService {
  bool completed = false;

  @override
  Future<void> setFirstLaunchCompleted() async => completed = true;
}

Widget _harness(FakeLocalStorageService storage) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const Text('LOGIN SCREEN')),
    ],
  );

  return ProviderScope(
    overrides: [localStorageProvider.overrideWithValue(storage)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows the first slide with a Next button', (tester) async {
    await tester.pumpWidget(_harness(FakeLocalStorageService()));
    await tester.pumpAndSettle();

    expect(find.text('Browse the Full Catalog'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
  });

  testWidgets('Skip completes onboarding and navigates to login immediately', (tester) async {
    final storage = FakeLocalStorageService();
    await tester.pumpWidget(_harness(storage));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(storage.completed, isTrue);
    expect(find.text('LOGIN SCREEN'), findsOneWidget);
  });

  testWidgets('paging through Next reaches the last slide, then Get Started completes onboarding', (tester) async {
    final storage = FakeLocalStorageService();
    await tester.pumpWidget(_harness(storage));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Pay Your Way'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(storage.completed, isTrue);
    expect(find.text('LOGIN SCREEN'), findsOneWidget);
  });
}
