import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/locale_controller.dart';
import '../../../core/theme/text_size_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/app_logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'delete_account_dialog.dart';
import 'settings_choices.dart';
import 'settings_popup.dart';
import 'settings_widgets.dart';

/// The Settings tab, shared by the retailer and admin profile screens so a
/// fix or new row lands in both. Everything is a tappable row opening a small
/// sheet, so the page stays short. [extraRows] lets each role add its own
/// first row (retailer: Notifications, admin: Delivery settings).
///
/// Callers must keep `profileControllerProvider` watched (both profile
/// screens already do) — it's autoDispose and the password-reset call awaits.
class SettingsList extends ConsumerWidget {
  final String email;
  final List<Widget> extraRows;

  /// Retailers can delete their own account; the owner's admin account is
  /// deliberately not self-deletable (it would strand the whole shop).
  final String? deleteAccountUid;

  const SettingsList({
    super.key,
    required this.email,
    this.extraRows = const [],
    this.deleteAccountUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final textSize = ref.watch(textSizeProvider);

    final sections = <Widget>[
      SettingsGroup(
        children: [
          ...extraRows,
          SettingsRow(
            icon: Icons.palette_outlined,
            title: l10n.profileAppearance,
            value: switch (themeMode) {
              ThemeMode.system => l10n.themeSystem,
              ThemeMode.light => l10n.themeLight,
              ThemeMode.dark => l10n.themeDark,
            },
            onTap: () => showSettingsPopup(
              context,
              title: l10n.profileAppearance,
              subtitle: l10n.settingsAppearanceSubtitle,
              icon: Icons.palette_rounded,
              doneLabel: l10n.settingsDone,
              child: const AppearanceChoice(),
            ),
          ),
          SettingsRow(
            icon: Icons.language,
            title: l10n.profileLanguage,
            value: switch (locale?.languageCode) {
              'hi' => l10n.languageHindi,
              'mr' => l10n.languageMarathi,
              _ => l10n.languageEnglish,
            },
            onTap: () => showSettingsPopup(
              context,
              title: l10n.profileLanguage,
              subtitle: l10n.settingsLanguageSubtitle,
              icon: Icons.language_rounded,
              doneLabel: l10n.settingsDone,
              child: const LanguageChoice(),
            ),
          ),
          SettingsRow(
            icon: Icons.text_fields_rounded,
            title: l10n.settingsTextSize,
            value: textSizeLabel(l10n, textSize),
            onTap: () => showSettingsPopup(
              context,
              title: l10n.settingsTextSize,
              subtitle: l10n.settingsTextSizeSubtitle,
              icon: Icons.text_fields_rounded,
              doneLabel: l10n.settingsDone,
              child: const TextSizeChoice(),
            ),
          ),
        ],
      ),
      SettingsGroup(
        children: [
          SettingsRow(
            icon: Icons.password_outlined,
            title: l10n.profileChangePassword,
            subtitle: email,
            onTap: () => _confirmChangePassword(context, ref, email),
          ),
          SettingsRow(
            icon: Icons.support_agent_outlined,
            title: l10n.profileSupport,
            onTap: () => showSupportSheet(context),
          ),
        ],
      ),
      SettingsGroup(
        children: [
          SettingsRow(
            icon: Icons.cleaning_services_outlined,
            title: l10n.settingsClearCache,
            subtitle: l10n.settingsClearCacheSubtitle,
            onTap: () => _clearImageCache(context),
          ),
          SettingsRow(
            icon: Icons.info_outline,
            title: l10n.settingsAbout,
            onTap: () => showSettingsPopup(
              context,
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutSubtitle,
              icon: Icons.info_rounded,
              child: const _AboutBody(),
            ),
          ),
          // Hidden until a real policy URL is configured (see
          // AppConstants.kPrivacyPolicyUrl).
          if (AppConstants.kPrivacyPolicyUrl.isNotEmpty)
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacyPolicy,
              onTap: () => _launch(Uri.parse(AppConstants.kPrivacyPolicyUrl)),
            ),
        ],
      ),
      if (deleteAccountUid != null)
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.delete_forever_outlined,
              title: l10n.settingsDeleteAccount,
              subtitle: l10n.settingsDeleteAccountSubtitle,
              color: AppColors.error,
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => DeleteAccountDialog(uid: deleteAccountUid!),
              ),
            ),
          ],
        ),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => confirmLogout(context, ref),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: Text(
            l10n.profileLogOut,
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < sections.length; i++)
          StaggeredEntrance(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: sections[i],
            ),
          ),
      ],
    );
  }
}

/// Call / WhatsApp / Email options in a sheet — also opened from the profile
/// screen's quick actions, so it is public.
Future<void> showSupportSheet(BuildContext context) => showSettingsPopup(
  context,
  title: AppLocalizations.of(context)!.profileSupport,
  subtitle: AppLocalizations.of(context)!.settingsSupportSubtitle,
  icon: Icons.support_agent_rounded,
  child: const _SupportOptions(),
);

/// Best-effort launch: a missing handler (no WhatsApp, no mail app) must not
/// throw into the UI.
Future<void> _launch(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    logWarning('Settings: could not open $uri', e);
  }
}

Future<void> _clearImageCache(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context)!.settingsCacheCleared;
  try {
    await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    logWarning('Settings: clearing the image cache failed', e);
  }
}

Future<void> _confirmChangePassword(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        l10n.profileChangePasswordDialogTitle,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      content: Text(
        l10n.profileResetLinkMessage(email),
        style: GoogleFonts.inter(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.profileSendLink),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(profileControllerProvider.notifier).sendPasswordReset(email);
  if (!context.mounted) return;
  final result = ref.read(profileControllerProvider);
  ScaffoldMessenger.of(context).showSnackBar(
    result.hasError
        ? SnackBar(
            content: Text(l10n.profileResetLinkFailed(result.error.toString())),
            backgroundColor: AppColors.error,
          )
        : SnackBar(content: Text(l10n.profileResetLinkSent(email))),
  );
}

/// Confirms before signing out — shared by Settings and the Home header so a
/// stray tap on the header icon can no longer log the retailer out.
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        l10n.profileLogoutDialogTitle,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
      ),
      content: Text(
        l10n.profileLogoutDialogContent,
        style: GoogleFonts.inter(fontSize: 13),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            l10n.profileLogOut,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    ref.read(authControllerProvider.notifier).signOut();
  }
}

/// Call / WhatsApp / Email as three large, tappable cards.
class _SupportOptions extends StatelessWidget {
  const _SupportOptions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <_SupportOption>[
      _SupportOption(
        icon: Icons.call_rounded,
        color: AppColors.primary,
        title: l10n.profileCallSupport,
        subtitle: AppConstants.kSupportPhone,
        onTap: () =>
            _launch(Uri(scheme: 'tel', path: AppConstants.kSupportPhone)),
      ),
      _SupportOption(
        icon: Icons.chat_rounded,
        color: AppColors.success,
        title: l10n.settingsWhatsAppSupport,
        subtitle: AppConstants.kSupportPhone,
        onTap: () => _launch(Uri.parse(AppConstants.kSupportWhatsAppUrl)),
      ),
      _SupportOption(
        icon: Icons.email_rounded,
        color: AppColors.accent,
        title: l10n.profileEmailSupport,
        subtitle: AppConstants.kSupportEmail,
        onTap: () =>
            _launch(Uri(scheme: 'mailto', path: AppConstants.kSupportEmail)),
      ),
    ];

    return Column(
      children: [
        for (final (index, option) in options.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          option.popupArrive(index),
        ],
      ],
    );
  }
}

class _SupportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SupportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: context.cardDecoration(radius: 20),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color.withOpacity(0.30)),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// App name + the installed build, so a support call can start with "which
/// version are you on?".
class _AboutBody extends ConsumerWidget {
  const _AboutBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final version = ref
        .watch(packageInfoProvider)
        .maybeWhen(
          data: (info) => l10n.settingsVersion(info.version, info.buildNumber),
          orElse: () => null, // no version line if the platform can't say
        );

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          RepaintBoundary(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryLight, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              )
              .animate(delay: kPopupTransition)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 560.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 18),
          Text(
            AppConstants.kAppName,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          if (version != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: context.inset,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                version,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
