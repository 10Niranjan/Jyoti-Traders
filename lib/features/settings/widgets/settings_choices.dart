import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/text_size_controller.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../l10n/app_localizations.dart';
import 'settings_popup.dart';

String textSizeLabel(AppLocalizations l10n, TextSize size) => switch (size) {
  TextSize.auto => l10n.settingsTextSizeAuto,
  TextSize.small => l10n.settingsTextSizeSmall,
  TextSize.medium => l10n.settingsTextSizeMedium,
  TextSize.large => l10n.settingsTextSizeLarge,
};

/// One big, tappable option in a settings pop-up. The chosen one gets a
/// brand-colour border and tint and a check badge that springs in.
class SettingsChoiceTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Put the check badge at the right edge, centred (a row layout), instead
  /// of the top-right corner (a card layout).
  final bool badgeCentered;

  const SettingsChoiceTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.badgeCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));
    final badge = AnimatedScale(
      scale: selected ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: selected
            ? Color.alphaBlend(
                AppColors.primary.withOpacity(0.10),
                context.surface,
              )
            : context.surface,
        border: Border.all(
          color: selected ? AppColors.primary : context.border,
          width: 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Stack(
            children: [
              Padding(padding: padding, child: child),
              if (badgeCentered)
                Positioned(
                  right: 14,
                  top: 0,
                  bottom: 0,
                  child: Center(child: badge),
                )
              else
                Positioned(top: 8, right: 8, child: badge),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Appearance ──────────────────────────────────────────────────────────

class AppearanceChoice extends ConsumerWidget {
  const AppearanceChoice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(themeModeProvider);
    final labels = {
      ThemeMode.system: l10n.themeSystem,
      ThemeMode.light: l10n.themeLight,
      ThemeMode.dark: l10n.themeDark,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, mode) in ThemeMode.values.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(
            child: SettingsChoiceTile(
              selected: mode == current,
              onTap: () =>
                  ref.read(themeModeProvider.notifier).setThemeMode(mode),
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
              child: Column(
                children: [
                  _MiniScreen(mode: mode),
                  const SizedBox(height: 12),
                  Text(
                    labels[mode]!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ).popupArrive(index),
          ),
        ],
      ],
    );
  }
}

/// A tiny drawing of the app in the given theme — enough to see what you are
/// choosing. "System" is the light and dark drawings cut in half.
class _MiniScreen extends StatelessWidget {
  final ThemeMode mode;

  const _MiniScreen({required this.mode});

  @override
  Widget build(BuildContext context) {
    const width = 72.0;
    const height = 96.0;
    final Widget drawing;
    switch (mode) {
      case ThemeMode.light:
        drawing = const _MiniApp(dark: false);
      case ThemeMode.dark:
        drawing = const _MiniApp(dark: true);
      case ThemeMode.system:
        drawing = Row(
          children: [
            _half(const _MiniApp(dark: false), Alignment.centerLeft),
            _half(const _MiniApp(dark: true), Alignment.centerRight),
          ],
        );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(width: width, height: height, child: drawing),
    );
  }

  Widget _half(Widget app, Alignment side) => SizedBox(
    width: 36,
    height: 96,
    child: ClipRect(
      child: OverflowBox(
        alignment: side,
        minWidth: 72,
        maxWidth: 72,
        child: app,
      ),
    ),
  );
}

class _MiniApp extends StatelessWidget {
  final bool dark;

  const _MiniApp({required this.dark});

  @override
  Widget build(BuildContext context) {
    final page = dark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final card = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final line = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    Widget row() => Container(
      height: 22,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.6,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 26,
          height: 4,
          decoration: BoxDecoration(
            color: line.withOpacity(0.55),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );

    return Container(
      width: 72,
      height: 96,
      color: page,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 8,
            decoration: BoxDecoration(
              color: dark ? Colors.white : AppColors.textPrimaryLight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 8),
          row(),
          const SizedBox(height: 6),
          row(),
          const Spacer(),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language ────────────────────────────────────────────────────────────

class LanguageChoice extends ConsumerWidget {
  const LanguageChoice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(localeProvider);
    final options = <(Locale?, String, String)>[
      (null, 'A', l10n.languageEnglish),
      (const Locale('hi'), 'हि', l10n.languageHindi),
      (const Locale('mr'), 'म', l10n.languageMarathi),
    ];

    return Column(
      children: [
        for (final (index, option) in options.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          SettingsChoiceTile(
            selected: option.$1?.languageCode == current?.languageCode,
            onTap: () => ref.read(localeProvider.notifier).setLocale(option.$1),
            badgeCentered: true,
            padding: const EdgeInsets.fromLTRB(14, 12, 54, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                  ),
                  child: Text(
                    option.$2,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    option.$3,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ).popupArrive(index),
        ],
      ],
    );
  }
}

// ── Text size ───────────────────────────────────────────────────────────

/// A 2×2 grid of "Aa" samples (drawn at their real size, whatever the app is
/// currently scaled to), then a line of sample text that rescales live as you
/// choose — so you see the result before closing.
class TextSizeChoice extends ConsumerWidget {
  const TextSizeChoice({super.key});

  // The "Aa" sample size for each choice.
  static const _sampleSize = {
    TextSize.auto: 26.0,
    TextSize.small: 20.0,
    TextSize.medium: 26.0,
    TextSize.large: 34.0,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(textSizeProvider);
    final sizes = TextSize.values;

    Widget tile(int index) {
      final size = sizes[index];
      final selected = size == current;
      return Expanded(
        child: SettingsChoiceTile(
          selected: selected,
          onTap: () => ref.read(textSizeProvider.notifier).setTextSize(size),
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      'Aa',
                      textScaler: TextScaler.noScaling,
                      style: GoogleFonts.inter(
                        fontSize: _sampleSize[size],
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.primary
                            : context.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  textSizeLabel(l10n, size),
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ).popupArrive(index),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [tile(0), const SizedBox(width: 10), tile(1)]),
        const SizedBox(height: 10),
        Row(children: [tile(2), const SizedBox(width: 10), tile(3)]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.inset,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            l10n.settingsTextSizePreview,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ).popupArrive(4),
        if (current == TextSize.auto) ...[
          const SizedBox(height: 12),
          Text(
            l10n.settingsTextSizeAutoHint,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: context.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
