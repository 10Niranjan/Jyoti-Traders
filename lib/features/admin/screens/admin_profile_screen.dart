import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/edit_basic_info_sheet.dart';
import '../../../shared/widgets/profile_header_card.dart';
import '../../../shared/widgets/section_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../profile/controllers/profile_controller.dart';

/// The admin/wholesaler's own account screen — identity in the "Profile" tab,
/// app-wide preferences and account actions in "Settings". Everything else
/// admin-specific (orders, retailers, products, categories, delivery
/// settings) already lives on its own screen off the dashboard.
class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> with SingleTickerProviderStateMixin {
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
      await ref.read(profileControllerProvider.notifier).updatePhoto(uid: uid, localFilePath: picked.path);
      if (!mounted) return;
      final result = ref.read(profileControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn\'t update photo: ${result.error}'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open the gallery: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _confirmChangePassword(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Change Password?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          'We\'ll send a password reset link to $email.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Send Link')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(profileControllerProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    final result = ref.read(profileControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t send reset link: ${result.error}'), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent to $email')),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Log out?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          'You\'ll need to sign in again to access the admin panel.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(authControllerProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    if (authState is! AuthenticatedAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;
    final unselectedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: unselectedColor,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
            Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
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
                  isScrollControlled: true,
                  shape:
                      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (_) => EditBasicInfoSheet(user: user, showShopName: false),
                ),
                onTapPhoto: () => _pickProfilePhoto(user.uid),
              ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {ref.watch(themeModeProvider)},
                  onSelectionChanged: (selection) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(selection.first),
                ),
              ),
              SectionCard(
                title: 'Store',
                icon: Icons.storefront_outlined,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  title: const Text('Delivery Settings'),
                  subtitle: const Text('Delivery radius, fees, and minimum order value'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RouteNames.adminDeliverySettings),
                ),
              ),
              SectionCard(
                title: 'Account',
                icon: Icons.lock_outline,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.password_outlined, color: AppColors.primary),
                  title: const Text('Change Password'),
                  subtitle: Text(user.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _confirmChangePassword(user.email),
                ),
              ),
              SectionCard(
                title: 'Support',
                icon: Icons.support_agent_outlined,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.call_outlined, color: AppColors.primary),
                      title: const Text('Call Support'),
                      subtitle: const Text(AppConstants.kSupportPhone),
                      onTap: () => launchUrl(Uri(scheme: 'tel', path: AppConstants.kSupportPhone)),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                      title: const Text('Email Support'),
                      subtitle: const Text(AppConstants.kSupportEmail),
                      onTap: () => launchUrl(Uri(scheme: 'mailto', path: AppConstants.kSupportEmail)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label:
                      const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
