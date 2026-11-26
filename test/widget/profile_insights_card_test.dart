import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/features/profile/controllers/profile_insights_controller.dart';
import 'package:traders_retailer/features/profile/widgets/profile_insights_card.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

Widget _host(RetailerInsights? insights) => ProviderScope(
  overrides: [retailerInsightsProvider.overrideWithValue(insights)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: ProfileInsightsCard())),
  ),
);

void main() {
  testWidgets('shows spend, trend, order count, top products and category', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const RetailerInsights(
          monthSpend: 12500,
          spendTrend: 25,
          monthOrders: 4,
          topProducts: [BoughtProduct('Rice', 6), BoughtProduct('Oil', 3)],
          topCategory: 'Grains',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your business'), findsOneWidget);
    expect(find.text('₹12,500'), findsOneWidget);
    expect(find.text('+25% vs same days last month'), findsOneWidget);
    expect(find.text('Orders this month: 4'), findsOneWidget);
    expect(find.text('Rice · 6'), findsOneWidget);
    expect(find.text('Oil · 3'), findsOneWidget);
    expect(find.text('Favourite category: Grains'), findsOneWidget);
  });

  testWidgets('leaves out the trend and category when they are unknown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const RetailerInsights(
          monthSpend: 800,
          spendTrend: null,
          monthOrders: 1,
          topProducts: [],
          topCategory: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('vs same days'), findsNothing);
    expect(find.text('Most bought'), findsNothing);
    expect(find.textContaining('Favourite category'), findsNothing);
    expect(find.text('₹800'), findsOneWidget);
  });

  testWidgets('renders nothing for a shop with no orders', (tester) async {
    await tester.pumpWidget(_host(null));
    await tester.pumpAndSettle();

    expect(find.text('Your business'), findsNothing);
  });
}
