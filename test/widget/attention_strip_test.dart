import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:traders_retailer/core/constants/route_names.dart';
import 'package:traders_retailer/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:traders_retailer/features/admin/widgets/admin_stat_card.dart';
import 'package:traders_retailer/features/admin/widgets/attention_strip.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

/// Hosts the strip on '/' with stub pages at the routes its chips open, so a
/// tap proves both *where* it goes and that it lands there.
Widget _host(AttentionSummary? summary) {
  Widget page(String label) => Scaffold(body: Center(child: Text(label)));
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: AttentionStrip()),
      ),
      GoRoute(
        path: RouteNames.adminApprovalQueue,
        builder: (_, _) => page('approval-queue-page'),
      ),
      GoRoute(
        path: RouteNames.adminOrders,
        builder: (_, _) => page('orders-page'),
      ),
      GoRoute(
        path: RouteNames.adminCatalog,
        builder: (_, _) => page('catalog-page'),
      ),
    ],
  );
  return ProviderScope(
    overrides: [attentionSummaryProvider.overrideWithValue(summary)],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

const _busy = AttentionSummary(
  pendingApprovals: 3,
  unconfirmedPayments: 2,
  lowStockProducts: 4,
  staleOrders: 1,
);

void main() {
  group('AttentionStrip', () {
    testWidgets('shows a chip with a count for each thing waiting', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_busy));
      await tester.pumpAndSettle();

      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('Retailer approvals'), findsOneWidget);
      expect(find.text('UPI payments to confirm'), findsOneWidget);
      expect(find.text('Low stock'), findsOneWidget);
      expect(find.text('Orders unconfirmed 30+ min'), findsOneWidget);
      for (final count in ['3', '2', '4', '1']) {
        expect(find.text(count), findsOneWidget);
      }
      expect(find.text("You're all caught up"), findsNothing);
    });

    testWidgets('omits chips whose count is zero', (tester) async {
      await tester.pumpWidget(
        _host(
          const AttentionSummary(
            pendingApprovals: 0,
            unconfirmedPayments: 0,
            lowStockProducts: 5,
            staleOrders: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Low stock'), findsOneWidget);
      expect(find.text('Retailer approvals'), findsNothing);
      expect(find.text('UPI payments to confirm'), findsNothing);
    });

    testWidgets('says so when nothing needs attention', (tester) async {
      await tester.pumpWidget(
        _host(
          const AttentionSummary(
            pendingApprovals: 0,
            unconfirmedPayments: 0,
            lowStockProducts: 0,
            staleOrders: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("You're all caught up"), findsOneWidget);
      expect(find.text('Retailer approvals'), findsNothing);
    });

    testWidgets('shows nothing at all until the data has loaded', (
      tester,
    ) async {
      await tester.pumpWidget(_host(null));
      await tester.pumpAndSettle();

      expect(find.text('Needs attention'), findsNothing);
      expect(find.text("You're all caught up"), findsNothing);
    });

    testWidgets('approvals opens the queue', (tester) async {
      await tester.pumpWidget(_host(_busy));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retailer approvals'));
      await tester.pumpAndSettle();

      expect(find.text('approval-queue-page'), findsOneWidget);
    });

    testWidgets('payments and stale orders open the Orders tab', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_busy));
      await tester.pumpAndSettle();
      await tester.tap(find.text('UPI payments to confirm'));
      await tester.pumpAndSettle();
      expect(find.text('orders-page'), findsOneWidget);

      await tester.pumpWidget(_host(_busy));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Orders unconfirmed 30+ min'));
      await tester.pumpAndSettle();
      expect(find.text('orders-page'), findsOneWidget);
    });

    testWidgets('low stock opens the Catalog tab', (tester) async {
      await tester.pumpWidget(_host(_busy));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Low stock'));
      await tester.pumpAndSettle();

      expect(find.text('catalog-page'), findsOneWidget);
    });
  });

  group('AdminStatCard trend', () {
    Widget card(double? trend) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AdminStatCard(
          title: "Today's Orders",
          value: const AsyncValue.data(5),
          icon: Icons.shopping_bag_outlined,
          color: Colors.green,
          trend: trend,
        ),
      ),
    );

    testWidgets('an increase reads as up with a plus sign', (tester) async {
      await tester.pumpWidget(card(12.4));
      await tester.pumpAndSettle();

      expect(find.text('+12% vs last week'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });

    testWidgets('a decrease reads as down', (tester) async {
      await tester.pumpWidget(card(-30));
      await tester.pumpAndSettle();

      expect(find.text('−30% vs last week'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    });

    testWidgets('a negligible change reads as flat, not +0%', (tester) async {
      await tester.pumpWidget(card(0.2));
      await tester.pumpAndSettle();

      expect(find.text('0% vs last week'), findsOneWidget);
      expect(find.byIcon(Icons.trending_flat_rounded), findsOneWidget);
    });

    testWidgets('no baseline means no trend line', (tester) async {
      await tester.pumpWidget(card(null));
      await tester.pumpAndSettle();

      expect(find.textContaining('vs last week'), findsNothing);
    });
  });
}
