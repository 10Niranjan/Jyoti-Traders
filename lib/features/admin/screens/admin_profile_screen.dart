import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/edit_basic_info_sheet.dart';
import '../../../shared/widgets/profile_header_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../settings/widgets/settings_list.dart';
import '../../settings/widgets/settings_widgets.dart';
import '../../profile/widgets/edit_sheet_frame.dart';
import '../widgets/business_profile_sheet.dart';
import '../../settings/controllers/business_profile_controller.dart';
import '../../../domain/entities/business_profile_entity.dart';
import 'delivery_settings_screen.dart';

/// The admin/wholesaler's own account screen — identity in the "Profile" tab,
/// app-wide preferences and account actions in "Settings". Everything else
/// admin-specific (orders, retailers, products, categories, delivery
/// settings) already lives on its own screen off the dashboard.
class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen>
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.profileUpdatePhotoError(result.error.toString()),
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

  /// Delivery settings used to be its own pushed screen; Phase 9.6 folds it
  /// in here as a sheet instead, reusing [DeliveryConfigFormView] (which
  /// already handles its own scrolling/keyboard-avoidance) unchanged — same
  /// `showModalBottomSheet` pattern this screen already uses for editing
  /// basic info.
  void _openDeliverySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // The form opens with its own hero card (which carries the title) and a
      // pinned Save bar, so it fills the sheet rather than sitting under a
      // heading.
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.92,
        child: const DeliveryConfigFormView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    if (authState is! AuthenticatedAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;
    final unselectedColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final business =
        ref.watch(businessProfileProvider).valueOrNull ??
        BusinessProfileEntity.empty;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminProfileTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.person_outline), text: l10n.navProfile),
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeaderCard(
                title: user.name,
                subtitleLines: [user.email, user.phone],
                photoUrl: user.photoUrl,
                isUploadingPhoto: profileState.isLoading,
                onEdit: () => showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) =>
                      EditBasicInfoSheet(user: user, showShopName: false),
                ),
                onTapPhoto: () => _pickProfilePhoto(user.uid),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: l10n.profileAccountInfo,
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(l10n.profileRoleLabel),
                      trailing: Text(
                        l10n.profileRoleAdmin,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.event_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        l10n.profileMemberSince(
                          formatOrderDate(user.createdAt),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SettingsGroup(
                children: [
                  SettingsRow(
                    icon: Icons.storefront_outlined,
                    title: l10n.profileBusinessDetails,
                    // The legal name is long-form, so it goes in the subtitle line.
                    subtitle: business.legalName.isEmpty
                        ? l10n.adminBusinessPrintedOnInvoices
                        : business.legalName,
                    value: business.legalName.isEmpty
                        ? l10n.profileValueNotSet
                        : null,
                    onTap: () => showEditSheet(
                      context,
                      child: BusinessProfileSheet(initial: business),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SettingsList(
            email: user.email,
            extraRows: [
              SettingsRow(
                icon: Icons.local_shipping_outlined,
                title: l10n.profileDeliverySettings,
                subtitle: l10n.profileDeliverySettingsSubtitle,
                onTap: () => _openDeliverySettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
