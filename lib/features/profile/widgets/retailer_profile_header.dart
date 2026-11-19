import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../l10n/app_localizations.dart';

/// One dense info pill inside the bento stat strip.
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.70)),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.60),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bento-style retailer profile header.
///
/// Replaces [ProfileHeaderCard] at the [_ProfileScreenState._buildProfileTab]
/// call site only. Admin screens continue using [ProfileHeaderCard] unchanged.
///
/// Visual breakdown:
/// - Dark [AppColors.primaryDark] rounded-rect card.
/// - Soft radial gradient glow behind the avatar (cheap depth, no 3D assets).
/// - Avatar row: photo + business name/owner name/phone + edit icon.
/// - Bento stat strip: Orders Placed | Total Business | Member Since.
class RetailerProfileHeader extends StatelessWidget {
  final UserModel user;
  final List<OrderEntity> orders;
  final bool isUploadingPhoto;
  final VoidCallback onEdit;
  final VoidCallback onTapPhoto;

  const RetailerProfileHeader({
    super.key,
    required this.user,
    required this.orders,
    required this.isUploadingPhoto,
    required this.onEdit,
    required this.onTapPhoto,
  });

  /// Compact ₹ formatter: ₹1.2L / ₹12.5k / ₹750
  static String _formatSpend(double amount) {
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}k';
    return '₹${amount.toInt()}';
  }

  Widget _buildAvatarContent() {
    if (user.photoUrl == null || user.photoUrl!.isEmpty) {
      return Text(
        user.businessName.initials.isNotEmpty ? user.businessName.initials : 'J',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    }
    return SizedBox(
      width: 60,
      height: 60,
      child: user.photoUrl!.startsWith('http')
          ? CachedNetworkImage(imageUrl: user.photoUrl!, fit: BoxFit.cover)
          : Image.file(File(user.photoUrl!), fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalSpend = orders.fold<double>(0, (sum, o) => sum + o.grandTotal.amount);
    final memberSince = DateFormat('MMM yyyy').format(user.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Radial glow — "Spline vibe": soft depth behind avatar, no 3D assets.
          Positioned(
            top: -35,
            left: -25,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.53),
                    AppColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Secondary glow accent (teal) top-right for depth variation.
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.27),
                    AppColors.accent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar + name row ─────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: isUploadingPhoto ? null : onTapPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.55),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withOpacity(0.16),
                              child: ClipOval(
                                child: isUploadingPhoto
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : _buildAvatarContent(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.businessName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            user.phone,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.60),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      tooltip: l10n.editProfileTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ── Bento stat strip ──────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      _StatPill(
                        label: 'Orders',
                        value: '${orders.length}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _StatPill(
                        label: 'Business',
                        value: _formatSpend(totalSpend),
                        icon: Icons.currency_rupee_rounded,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      _StatPill(
                        label: 'Since',
                        value: memberSince,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
