import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/edit_basic_info_sheet.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../orders/controllers/order_controller.dart';
import '../../settings/widgets/settings_list.dart';
import '../../settings/widgets/settings_widgets.dart';
import '../../settings/widgets/settings_popup.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_insights_controller.dart';
import '../utils/profile_completeness.dart';
import '../widgets/address_sheet.dart';
import '../widgets/business_details_sheet.dart';
import '../widgets/edit_sheet_frame.dart';
import '../widgets/notification_prefs_body.dart';
import '../widgets/payout_sheet.dart';
import '../widgets/profile_completeness_card.dart';
import '../widgets/profile_insights_card.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/retailer_profile_header.dart';
import '../widgets/saved_addresses_sheet.dart';

/// The retailer's account screen. The Profile tab is a short overview —
/// header, what's left to fill in, shortcuts, business insights — with each
/// editable section (address, business details, payout) behind its own row
/// and sheet, so it is saved and guarded on its own instead of sharing one
/// Save button at the bottom of a long form.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto(String uid) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      await ref
          .read(profileControllerProvider.notifier)
          .updatePhoto(uid: uid, localFilePath: picked.path);
      if (!mounted) return;
      final result = ref.read(profileControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.profileUpdatePhotoError(result.error.toString()),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.upiGalleryError(e.toString()),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openTask(ProfileTask task, UserModel user) => switch (task) {
    ProfileTask.photo => _pickProfilePhoto(user.uid),
    ProfileTask.location => showEditSheet(
      context,
      child: AddressSheet(user: user),
    ),
    ProfileTask.gst => showEditSheet(
      context,
      child: BusinessDetailsSheet(user: user),
    ),
    ProfileTask.payout => showEditSheet(
      context,
      child: PayoutSheet(user: user),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    if (authState is! AuthenticatedCustomer) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;
    final unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navProfile,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_outlined),
              text: l10n.navProfile,
            ),
            Tab(
              icon: const Icon(Icons.settings_outlined),
              text: l10n.profileSettingsTab,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(user, profileState),
          _buildSettingsTab(user),
        ],
      ),
    );
  }

  Widget _buildProfileTab(UserModel user, AsyncValue<void> profileState) {
    final l10n = AppLocalizations.of(context)!;
    final orders =
        ref.watch(orderHistoryProvider).valueOrNull ?? const <OrderEntity>[];
    final hasInsights = ref.watch(retailerInsightsProvider) != null;
    final completeness = computeProfileCompleteness(user);
    final address = user.address;
    final bank = user.bankDetails;
    final account = bank?.accountNumber ?? '';
    final upi = bank?.upiId ?? '';
    final notSet = l10n.profileValueNotSet;

    final sections = <Widget>[
      RetailerProfileHeader(
        user: user,
        orders: orders,
        isUploadingPhoto: profileState.isLoading,
        onEdit: () => showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => EditBasicInfoSheet(user: user),
        ),
        onTapPhoto: () => _pickProfilePhoto(user.uid),
      ),
      if (!completeness.isComplete)
        ProfileCompletenessCard(
          completeness: completeness,
          onTask: (task) => _openTask(task, user),
        ),
      ProfileQuickActions(
        onAddresses: () =>
            showEditSheet(context, child: const SavedAddressesSheet()),
        onSupport: () => showSupportSheet(context),
      ),
      if (hasInsights) const ProfileInsightsCard(),
      SettingsGroup(
        children: [
          SettingsRow(
            icon: Icons.place_outlined,
            title: l10n.checkoutDeliveryAddress,
            value: address == null ? notSet : address.label,
            subtitle: address == null
                ? null
                : '${address.street}, ${address.city} ${address.pincode}',
            onTap: () =>
                showEditSheet(context, child: AddressSheet(user: user)),
          ),
          if (user.savedAddresses.isNotEmpty)
            SettingsRow(
              icon: Icons.bookmarks_outlined,
              title: l10n.profileSavedAddresses,
              value: '${user.savedAddresses.length}',
              onTap: () =>
                  showEditSheet(context, child: const SavedAddressesSheet()),
            ),
          SettingsRow(
            icon: Icons.storefront_outlined,
            title: l10n.profileBusinessDetails,
            value: (user.gstNumber?.isNotEmpty ?? false)
                ? user.gstNumber
                : notSet,
            onTap: () =>
                showEditSheet(context, child: BusinessDetailsSheet(user: user)),
          ),
          SettingsRow(
            icon: Icons.account_balance_outlined,
            title: l10n.profilePayoutDetails,
            value: account.isNotEmpty
                ? '••${account.length > 4 ? account.substring(account.length - 4) : account}'
                : (upi.isEmpty ? notSet : null),
            subtitle: upi.isEmpty ? null : upi,
            onTap: () => showEditSheet(context, child: PayoutSheet(user: user)),
          ),
        ],
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

  Widget _buildSettingsTab(UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsList(
      email: user.email,
      deleteAccountUid: user.uid,
      extraRows: [
        SettingsRow(
          icon: Icons.notifications_outlined,
          title: l10n.profileNotifications,
          onTap: () => showSettingsPopup(
            context,
            title: l10n.profileNotifications,
            subtitle: l10n.settingsNotificationsSubtitle,
            icon: Icons.notifications_active_rounded,
            doneLabel: l10n.settingsDone,
            child: NotificationPrefsBody(uid: user.uid),
          ),
        ),
      ],
    );
  }
}
