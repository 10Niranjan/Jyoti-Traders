import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../controllers/profile_controller.dart';
import 'edit_sheet_frame.dart';

/// Every address the retailer has saved (at checkout), with one marked as the
/// default delivery address. Reads the live user, so a change made here is
/// reflected immediately without closing the sheet.
class SavedAddressesSheet extends ConsumerWidget {
  const SavedAddressesSheet({super.key});

  /// The default is the profile's own `address`. A saved entry is "the
  /// default" when it is that address — by id if the default was copied from a
  /// saved entry, otherwise by what it says.
  static bool isDefault(AddressEntity? current, AddressEntity saved) {
    if (current == null) return false;
    if (current.id != null && saved.id != null) return current.id == saved.id;
    return current.street == saved.street &&
        current.city == saved.city &&
        current.pincode == saved.pincode;
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    String uid,
    List<AddressEntity> all,
    AddressEntity address,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final label = address.label?.isNotEmpty == true
        ? address.label!
        : address.street;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.profileRemoveAddressTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          l10n.profileRemoveAddressContent(label),
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
              l10n.profileRemoveAddressAction,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          uid: uid,
          savedAddresses: all.where((a) => a.id != address.id).toList(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authControllerProvider);
    if (auth is! AuthenticatedCustomer) return const SizedBox.shrink();
    final user = auth.user;

    return EditSheetFrame(
      title: l10n.profileSavedAddresses,
      dirty: false,
      child: user.savedAddresses.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text(l10n.profileNoSavedAddresses)),
            )
          : Column(
              children: [
                for (final address in user.savedAddresses)
                  _AddressTile(
                    address: address,
                    isDefault: isDefault(user.address, address),
                    onMakeDefault: () => ref
                        .read(profileControllerProvider.notifier)
                        .updateProfile(uid: user.uid, address: address),
                    onRemove: () => _remove(
                      context,
                      ref,
                      user.uid,
                      user.savedAddresses,
                      address,
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressEntity address;
  final bool isDefault;
  final VoidCallback onMakeDefault;
  final VoidCallback onRemove;

  const _AddressTile({
    required this.address,
    required this.isDefault,
    required this.onMakeDefault,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Tooltip(
        message: isDefault ? l10n.profileDefaultBadge : l10n.profileSetDefault,
        child: IconButton(
          icon: Icon(
            isDefault ? Icons.star_rounded : Icons.star_border_rounded,
            color: isDefault ? AppColors.warning : context.textSecondary,
          ),
          onPressed: isDefault ? null : onMakeDefault,
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              address.label?.isNotEmpty == true ? address.label! : address.street,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.profileDefaultBadge,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${address.street}, ${address.city} ${address.pincode}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        tooltip: l10n.profileRemoveAddressAction,
        onPressed: onRemove,
      ),
    );
  }
}
