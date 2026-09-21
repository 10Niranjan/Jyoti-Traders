import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/constants/app_colors.dart';

import '../helpers/theme_builder.dart';

/// WCAG contrast ratio between two colours.
double _contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  for (final name in ['light', 'dark']) {
    final dark = name == 'dark';

    group('$name theme', () {
      // Regression: `bodyMedium` — the style every un-coloured `Text` renders
      // in — used to be the muted secondary colour, which faded every title,
      // price and total that forgot to set one.
      testWidgets('default text is readable on the page and on a card', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        final color = theme.textTheme.bodyMedium!.color!;
        expect(
          _contrast(color, theme.scaffoldBackgroundColor),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(color, theme.colorScheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      });

      testWidgets('default text is the primary colour, not the muted one', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        expect(
          theme.textTheme.bodyMedium!.color,
          dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        );
      });

      testWidgets('secondary text stays readable on the page and on a card', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        final color = theme.textTheme.bodySmall!.color!;
        expect(
          _contrast(color, theme.scaffoldBackgroundColor),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(color, theme.colorScheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      });

      testWidgets('Material subtitles/hints (onSurfaceVariant) are readable', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        expect(
          _contrast(
            theme.colorScheme.onSurfaceVariant,
            theme.colorScheme.surface,
          ),
          greaterThanOrEqualTo(4.5),
        );
      });

      // Regression: the dark theme had no divider theme, so Material drew a
      // bright white rule across the Cart totals.
      testWidgets('divider is visible but is not a bright line', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        final ratio = _contrast(
          theme.dividerTheme.color!,
          theme.colorScheme.surface,
        );
        expect(ratio, greaterThan(1.1));
        expect(ratio, lessThan(2.0));
      });

      // Regression: an unthemed ElevatedButton rendered as orange text on a
      // near-invisible surface ("Save Changes" in Delivery Settings).
      testWidgets('elevated button has a filled primary background', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        final style = theme.elevatedButtonTheme.style!;
        expect(style.backgroundColor!.resolve({}), AppColors.primary);
        expect(style.foregroundColor!.resolve({}), Colors.white);
      });

      // Regression: building the scheme with `copyWith(primary: …)` left the
      // *container* roles at Material's stock purple/teal, so a selected
      // SegmentedButton segment rendered bright cyan.
      testWidgets('selected/container colours are tinted from the brand', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        final brandHue = HSLColor.fromColor(AppColors.primary).hue;
        for (final container in [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ]) {
          final diff = (HSLColor.fromColor(container).hue - brandHue).abs();
          expect(math.min(diff, 360 - diff), lessThan(25));
        }
        expect(
          _contrast(
            theme.colorScheme.onSecondaryContainer,
            theme.colorScheme.secondaryContainer,
          ),
          greaterThanOrEqualTo(4.5),
        );
      });

      testWidgets('bottom sheets and dialogs use the theme surface', (
        tester,
      ) async {
        final theme = buildTheme(dark: dark);
        expect(
          theme.bottomSheetTheme.backgroundColor,
          theme.colorScheme.surface,
        );
        expect(theme.dialogTheme.backgroundColor, theme.colorScheme.surface);
      });
    });
  }

  // 3:1 — the bar for bold UI text; the Saffron brand colour is the ceiling
  // here, not the theme. Theme-independent, so it lives outside the loop.
  test('button label is legible on the primary fill', () {
    expect(
      _contrast(Colors.white, AppColors.primary),
      greaterThanOrEqualTo(3.0),
    );
  });
}
