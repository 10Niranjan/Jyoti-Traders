import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/notification_preferences_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../controllers/profile_controller.dart';

/// The three notification switches, shown in a Settings sheet. State is kept
/// locally so a switch flips instantly; the save goes through the profile
/// controller, and the app's notification code reads the saved value back via
/// `notificationPreferencesProvider`.
///
/// Relies on the profile screen underneath keeping the (autoDispose)
/// `profileControllerProvider` watched while this sheet is open.
class NotificationPrefsBody extends ConsumerStatefulWidget {
  final String uid;

  const NotificationPrefsBody({super.key, required this.uid});

  @override
  ConsumerState<NotificationPrefsBody> createState() =>
      _NotificationPrefsBodyState();
}

class _NotificationPrefsBodyState extends ConsumerState<NotificationPrefsBody> {
  late NotificationPreferencesEntity _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = ref.read(notificationPreferencesProvider);
  }

  Future<void> _update(NotificationPreferencesEntity next) async {
    setState(() => _prefs = next);
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(uid: widget.uid, notificationPreferences: next);
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.profileSaveFailed(result.error.toString()),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.profileOrderUpdates),
          subtitle: Text(l10n.profileOrderUpdatesSubtitle),
          value: _prefs.orderUpdates,
          onChanged: (v) => _update(_prefs.copyWith(orderUpdates: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.profilePromotions),
          subtitle: Text(l10n.profilePromotionsSubtitle),
          value: _prefs.promotions,
          onChanged: (v) => _update(_prefs.copyWith(promotions: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.profileLowStockAlerts),
          subtitle: Text(l10n.profileLowStockAlertsSubtitle),
          value: _prefs.lowStockAlerts,
          onChanged: (v) => _update(_prefs.copyWith(lowStockAlerts: v)),
        ),
      ],
    );
  }
}
