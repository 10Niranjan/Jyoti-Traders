import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/promo_banner_entity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/status_pill.dart';
import '../controllers/admin_banner_controller.dart';
import '../widgets/banner_editor_sheet.dart';

/// Admin's list of Home banners — add, edit, switch on/off, delete.
class ManageBannersScreen extends ConsumerWidget {
  const ManageBannersScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PromoBannerEntity banner,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.adminBannerDeleteTitle),
        content: Text(l10n.adminBannerDeleteContent(banner.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.adminCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.adminDelete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final deleted = await ref
        .read(adminBannerControllerProvider.notifier)
        .delete(banner.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? l10n.adminBannerDeleted
              : l10n.adminUpdateFailed(
                  '${ref.read(adminBannerControllerProvider).error}',
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bannersAsync = ref.watch(promoBannersProvider);
    // Watched so the autoDispose controller outlives each async write.
    final isSaving = ref.watch(adminBannerControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.adminBannersTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBannerEditorSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminBannerAdd),
      ),
      body: bannersAsync.when(
        loading: () => const ListShimmerLoader(),
        error: (_, _) => ErrorStateWidget(
          onRetry: () => ref.invalidate(promoBannersProvider),
        ),
        data: (banners) {
          if (banners.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.view_carousel_outlined,
              title: l10n.adminBannersEmptyTitle,
              message: l10n.adminBannersEmptyMessage,
            );
          }
          return ListView.separated(
            // Bottom padding clears the extended FAB.
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: banners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _BannerTile(
              banner: banners[index],
              enabled: !isSaving,
              onEdit: () =>
                  showBannerEditorSheet(context, banner: banners[index]),
              onDelete: () => _confirmDelete(context, ref, banners[index]),
              onToggle: (v) => ref
                  .read(adminBannerControllerProvider.notifier)
                  .setActive(banners[index].id, v),
            ),
          );
        },
      ),
    );
  }
}

class _BannerTile extends StatelessWidget {
  final PromoBannerEntity banner;
  final bool enabled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _BannerTile({
    required this.banner,
    required this.enabled,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expired = banner.isExpiredAt(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (banner.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      banner.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                  if (banner.endsAt != null) ...[
                    const SizedBox(height: 8),
                    expired
                        ? StatusPill(
                            label: l10n.adminBannerExpired,
                            color: AppColors.error,
                          )
                        : StatusPill(
                            label: l10n.adminBannerUntil(
                              formatOrderDate(banner.endsAt!),
                            ),
                            color: AppColors.primary,
                          ),
                  ],
                ],
              ),
            ),
            Switch(
              value: banner.isActive,
              onChanged: enabled ? onToggle : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n.adminEdit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: l10n.adminDelete,
              onPressed: enabled ? onDelete : null,
            ),
          ],
        ),
      ),
    );
  }
}
