import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/theme_colors.dart';
import 'package:traders_retailer/shared/widgets/qty_stepper.dart';
import 'package:traders_retailer/shared/widgets/summary_row.dart';

import '../helpers/theme_builder.dart';

double _contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final name in ['light', 'dark']) {
    final dark = name == 'dark';

    group('$name theme', () {
      // Regression: the stepper pill was filled with `cardBorder` (near-white)
      // in both themes, so in dark mode its white digits were invisible.
      testWidgets('QtyStepper digits are readable on the pill', (tester) async {
        final theme = buildTheme(dark: dark);
        await tester.pumpWidget(
          _host(theme, QtyStepper(qty: 23, onChanged: (_) {})),
        );

        final pill = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(QtyStepper),
                matching: find.byType(Container),
              )
              .first,
        );
        final fill = (pill.decoration! as BoxDecoration).color!;
        final digits = tester.widget<Text>(find.text('23'));

        expect(
          _contrast(digits.style!.color!, fill),
          greaterThanOrEqualTo(4.5),
        );
      });

      // Regression: totals inherited the muted default text colour.
      testWidgets('SummaryRow amount is full-strength, bold label too', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        late BuildContext context;
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (c) {
                context = c;
                return const SummaryRow(
                  label: 'Total',
                  value: '₹51,850',
                  bold: true,
                );
              },
            ),
          ),
        );

        final value = tester.widget<Text>(find.text('₹51,850'));
        final label = tester.widget<Text>(find.text('Total'));
        expect(value.style!.color, context.textPrimary);
        expect(label.style!.color, context.textPrimary);
      });

      testWidgets('a plain SummaryRow label steps back, its amount does not', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        late BuildContext context;
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (c) {
                context = c;
                return const SummaryRow(label: 'Subtotal', value: '₹51,750');
              },
            ),
          ),
        );

        expect(
          tester.widget<Text>(find.text('Subtotal')).style!.color,
          context.textSecondary,
        );
        expect(
          tester.widget<Text>(find.text('₹51,750')).style!.color,
          context.textPrimary,
        );
      });

      testWidgets('cardDecoration has a fill, a visible border and a shadow '
          'only in light mode', (tester) async {
        final theme = buildTheme(dark: dark);
        late BoxDecoration decoration;
        late Color page;
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (c) {
                decoration = c.cardDecoration();
                page = Theme.of(c).scaffoldBackgroundColor;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(decoration.color, isNot(page));
        final border = (decoration.border! as Border).top.color;
        expect(_contrast(border, decoration.color!), greaterThan(1.1));
        if (dark) {
          expect(decoration.boxShadow, isNull);
        } else {
          expect(decoration.boxShadow, isNotEmpty);
        }
      });
    });
  }
}
