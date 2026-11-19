import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../l10n/app_localizations.dart';

/// Four shortcuts under the header: Orders, Wishlist, Addresses, Support.
/// Wishlist used to be reachable only from Home's heart icon.
class ProfileQuickActions extends StatelessWidget {
  final VoidCallback onAddresses;
  final VoidCallback onSupport;

  const ProfileQuickActions({
    super.key,
    required this.onAddresses,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _Action(
          icon: Icons.receipt_long_outlined,
          label: l10n.navOrders,
          // A shell tab: `go` switches to it, `push` would stack on this one.
          onTap: () => context.go(RouteNames.orders),
        ),
        _Action(
          icon: Icons.favorite_border_rounded,
          label: l10n.wishlistTitle,
          onTap: () => context.push(RouteNames.wishlist),
        ),
        _Action(
          icon: Icons.place_outlined,
          label: l10n.profileQuickAddresses,
          onTap: onAddresses,
        ),
        _Action(
          icon: Icons.support_agent_outlined,
          label: l10n.profileSupport,
          onTap: onSupport,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
