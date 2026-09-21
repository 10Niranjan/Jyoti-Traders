import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// The inbox's header card: the unread count at a glance, a bell that rings
/// once when there is something new, and the "Mark all read" action.
///
/// A saffron gradient with two soft glows — the same visual language as the
/// Profile header, so the two screens read as one family.
class NotificationHero extends StatelessWidget {
  final int unread;
  final int total;
  final VoidCallback onMarkAllRead;

  const NotificationHero({
    super.key,
    required this.unread,
    required this.total,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caughtUp = unread == 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -44,
            child: _Glow(size: 170, color: Colors.white.withOpacity(0.14)),
          ),
          Positioned(
            left: -28,
            bottom: -56,
            child: _Glow(
              size: 140,
              color: AppColors.accentLight.withOpacity(0.30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BellBadge(ring: !caughtUp),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caughtUp
                                ? l10n.notificationsHeroCaughtUp
                                : l10n.notificationsHeroUnread(unread),
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.notificationsHeroSubtitle(total),
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!caughtUp) ...[
                  const SizedBox(height: 18),
                  _GlassPill(
                    label: l10n.notificationsMarkAllRead,
                    icon: Icons.done_all_rounded,
                    onTap: onMarkAllRead,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BellBadge extends StatelessWidget {
  final bool ring;

  const _BellBadge({required this.ring});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      ring ? Icons.notifications_active_rounded : Icons.done_all_rounded,
      size: 30,
      color: Colors.white,
    );
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.32)),
      ),
      // Rings once after the card has settled — a finite effect on purpose:
      // a looping one would keep the screen animating forever.
      child: ring
          ? icon
                .animate(delay: 500.ms)
                .shake(hz: 4, rotation: 0.16, duration: 700.ms)
          : icon,
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.20),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.34)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}
