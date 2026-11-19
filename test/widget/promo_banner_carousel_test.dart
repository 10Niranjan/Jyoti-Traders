import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/promo_banner_entity.dart';
import 'package:traders_retailer/features/admin/controllers/admin_banner_controller.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/promo_banner_carousel.dart';

import '../helpers/fake_promo_banner_repository.dart';

Widget _wrap(List<PromoBannerEntity> offers) => ProviderScope(
  overrides: [activePromoBannersProvider.overrideWithValue(offers)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: PromoBannerCarousel()),
  ),
);

void main() {
  testWidgets('with no admin banners it shows the fixed informational slide', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const []));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    expect(find.text(l10n.promoMinOrderTitle), findsOneWidget);
  });

  testWidgets('an admin banner leads the carousel, ahead of the fixed slides', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const [
        PromoBannerEntity(id: 'b1', title: 'Diwali kit', body: 'Bundle offer'),
      ]),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
    expect(find.text('Diwali kit'), findsOneWidget);
    expect(find.text('Bundle offer'), findsOneWidget);
    expect(find.text(l10n.promoMinOrderTitle), findsNothing);
  });

  test(
    'only banners that are switched on and not expired reach retailers',
    () async {
      final repo = FakePromoBannerRepository([
        const PromoBannerEntity(id: 'live', title: 'Live'),
        const PromoBannerEntity(id: 'off', title: 'Off', isActive: false),
        PromoBannerEntity(
          id: 'old',
          title: 'Old',
          endsAt: DateTime(2020, 1, 1),
        ),
        PromoBannerEntity(
          id: 'future',
          title: 'Future',
          endsAt: DateTime.now().add(const Duration(days: 2)),
        ),
      ]);
      final container = ProviderContainer(
        overrides: [
          promoBannersProvider.overrideWith((ref) => repo.watchBanners()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(promoBannersProvider.future);
      expect(container.read(activePromoBannersProvider).map((b) => b.id), [
        'live',
        'future',
      ]);
    },
  );
}
