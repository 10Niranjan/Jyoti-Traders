import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/promo_banner_entity.dart';
import 'package:traders_retailer/features/admin/screens/manage_banners_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_promo_banner_repository.dart';
import '../helpers/test_viewport.dart';

Widget _wrap(FakePromoBannerRepository repo) => ProviderScope(
  overrides: [promoBannerRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ManageBannersScreen(),
  ),
);

void main() {
  useTallTestViewport();

  testWidgets('shows the empty state when there are no banners', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakePromoBannerRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No banners yet'), findsOneWidget);
  });

  testWidgets('adding a banner saves it and lists it', (tester) async {
    final repo = FakePromoBannerRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Diwali kit',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Message (optional)'),
      'Bundle offer',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.banners.single.title, 'Diwali kit');
    expect(repo.banners.single.body, 'Bundle offer');
    expect(repo.banners.single.isActive, isTrue);
    expect(find.text('Banner saved'), findsOneWidget);
    expect(find.text('Diwali kit'), findsOneWidget);
  });

  testWidgets('a banner with no title is rejected and nothing is saved', (
    tester,
  ) async {
    final repo = FakePromoBannerRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a title'), findsOneWidget);
    expect(repo.banners, isEmpty);
  });

  testWidgets('the switch turns a banner off without deleting it', (
    tester,
  ) async {
    final repo = FakePromoBannerRepository([
      const PromoBannerEntity(id: 'b1', title: 'Rice ₹2/kg off'),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(repo.banners.single.isActive, isFalse);
  });

  testWidgets(
    'deleting asks for confirmation first, then removes only that banner',
    (tester) async {
      final repo = FakePromoBannerRepository([
        const PromoBannerEntity(id: 'b1', title: 'Diwali kit'),
        const PromoBannerEntity(id: 'b2', title: 'Rice offer'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('Delete banner?'), findsOneWidget);
      expect(
        repo.banners,
        hasLength(2),
      ); // nothing yet — still awaiting confirmation

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repo.banners.map((b) => b.id), ['b2']);
      expect(find.text('Banner deleted'), findsOneWidget);
    },
  );

  testWidgets('a banner past its end date is flagged as expired', (
    tester,
  ) async {
    final repo = FakePromoBannerRepository([
      PromoBannerEntity(
        id: 'b1',
        title: 'Old offer',
        endsAt: DateTime(2020, 1, 1),
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    expect(find.text('Expired'), findsOneWidget);
  });
}
