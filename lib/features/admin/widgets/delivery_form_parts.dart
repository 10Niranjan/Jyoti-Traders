import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';

/// Icon tile + title (+ optional hint) heading a card in Delivery Settings.
class DeliveryCardHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const DeliveryCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.26),
                AppColors.primary.withOpacity(0.10),
              ],
            ),
            border: Border.all(color: AppColors.primary.withOpacity(0.28)),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ).animate().scale(
          begin: const Offset(0.7, 0.7),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      height: 1.35,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One-tap rates, so the common case never needs the keyboard. The chip
/// matching the current rate is filled.
class DeliveryQuickRates extends StatelessWidget {
  static const rates = [5, 8, 10, 12, 15];

  final double? current;
  final ValueChanged<int> onPick;

  const DeliveryQuickRates({
    super.key,
    required this.current,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminDeliveryQuickRates,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final rate in rates)
              _RateChip(
                rate: rate,
                selected: current == rate.toDouble(),
                onTap: () => onPick(rate),
              ),
          ],
        ),
      ],
    );
  }
}

class _RateChip extends StatelessWidget {
  final int rate;
  final bool selected;
  final VoidCallback onTap;

  const _RateChip({
    required this.rate,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: ShapeDecoration(
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : context.border,
          ),
        ),
        color: selected ? AppColors.primary : context.surface,
        shadows: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              formatRupees(rate.toDouble()),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : context.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ‑ / + beside the rate field.
class DeliveryStepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const DeliveryStepButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        minimumSize: const Size(52, 52),
        backgroundColor: AppColors.primary.withOpacity(0.14),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Pinned to the bottom of the sheet: says whether there is anything to save,
/// and holds the one button that saves it — enabled only when something
/// changed, so a tap always means something.
class DeliverySaveBar extends StatelessWidget {
  final bool dirty;
  final bool isSaving;
  final VoidCallback onSave;

  const DeliverySaveBar({
    super.key,
    required this.dirty,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = dirty ? AppColors.warning : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Row(
                  key: ValueKey(dirty),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      dirty
                          ? Icons.edit_note_rounded
                          : Icons.check_circle_rounded,
                      size: 17,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dirty
                          ? l10n.adminDeliveryUnsaved
                          : l10n.adminDeliveryAllSaved,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: l10n.adminSaveChanges,
                onPressed: dirty ? onSave : null,
                isLoading: isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
