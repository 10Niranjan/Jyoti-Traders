import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_card.dart';
import '../utils/profile_completeness.dart';

/// Progress ring plus one tappable prompt per thing still missing, each
/// opening the place to fix it. The caller hides this once the profile is
/// complete.
class ProfileCompletenessCard extends StatelessWidget {
  final ProfileCompleteness completeness;
  final ValueChanged<ProfileTask> onTask;

  const ProfileCompletenessCard({
    super.key,
    required this.completeness,
    required this.onTask,
  });

  static (IconData, String Function(AppLocalizations)) _describe(
    ProfileTask task,
  ) => switch (task) {
    ProfileTask.photo => (Icons.add_a_photo_outlined, (l) => l.profileTaskPhoto),
    ProfileTask.location => (
      Icons.my_location_outlined,
      (l) => l.profileTaskLocation,
    ),
    ProfileTask.gst => (Icons.receipt_long_outlined, (l) => l.profileTaskGst),
    ProfileTask.payout => (
      Icons.account_balance_outlined,
      (l) => l.profileTaskPayout,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SectionCard(
      title: l10n.profileCompleteTitle(completeness.percent),
      subtitle: l10n.profileCompleteSubtitle,
      icon: Icons.task_alt_outlined,
      trailing: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: completeness.done / completeness.total,
              strokeWidth: 4,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              color: AppColors.primary,
            ),
            Text(
              '${completeness.percent}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          for (final task in completeness.missing)
            Builder(
              builder: (context) {
                final (icon, label) = _describe(task);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon, color: AppColors.primary, size: 20),
                  title: Text(
                    label(l10n),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.textSecondary,
                  ),
                  onTap: () => onTask(task),
                );
              },
            ),
        ],
      ),
    );
  }
}
