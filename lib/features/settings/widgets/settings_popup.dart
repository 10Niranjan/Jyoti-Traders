import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../shared/widgets/primary_button.dart';

/// How long the card takes to arrive. Everything inside it waits this long
/// before animating, so while the card scales in it is a still picture the GPU
/// can cache — animating its contents at the same time forces the whole card
/// to be redrawn every frame, which is what made it stutter on a mid-range phone.
const kPopupTransition = Duration(milliseconds: 380);

/// Fade + slide-up for one option inside a pop-up, staggered by [index] and
/// starting once the card has landed. Each option is its own repaint boundary,
/// so animating it never redraws the rest of the card.
extension PopupArrival on Widget {
  Widget popupArrive(int index) => RepaintBoundary(child: this)
      .animate(
        delay: Duration(
          milliseconds: kPopupTransition.inMilliseconds + 20 + index * 60,
        ),
      )
      .fadeIn(duration: 240.ms, curve: Curves.easeOut)
      .slideY(
        begin: 0.14,
        end: 0,
        duration: 260.ms,
        curve: Curves.easeOutCubic,
      );
}

/// Opens a settings choice as a big card in the middle of the page — the
/// page behind dims, the card zooms in with a soft spring, and its header
/// badge pops once it has landed. Used for every choice in Settings
/// (appearance, language, text size, support, about, notifications).
///
/// No background blur on purpose: a blur has to be recomputed for the whole
/// screen on every animation frame, which is far too heavy for mid-range GPUs.
///
/// Give [doneLabel] for pickers whose choice applies instantly: it adds a
/// full-width button that closes the card. Tapping outside, or the ✕, also
/// closes it.
Future<void> showSettingsPopup(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Widget child,
  String? doneLabel,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    // The scrim below is drawn by the transition so it can fade with the card.
    barrierColor: Colors.transparent,
    transitionDuration: reduceMotion ? Duration.zero : kPopupTransition,
    pageBuilder: (context, _, _) => _SettingsPopup(
      title: title,
      subtitle: subtitle,
      icon: icon,
      doneLabel: doneLabel,
      child: child,
    ),
    transitionBuilder: (context, animation, _, page) {
      // A soft spring: the control point sits just above 1.0, so the card
      // overshoots by a few percent and settles. (`easeOutBack` overshoots
      // ~10%, which reads as a bounce and looks laggy at 60 fps.) It must
      // only drive scale — never opacity.
      final spring = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.2, 0.85, 0.3, 1.12),
        reverseCurve: Curves.easeInCubic,
      );
      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.55, curve: Curves.easeOut),
      );
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              // A flat dim: fading a single colour costs almost nothing.
              child: FadeTransition(
                opacity: animation,
                child: ColoredBox(color: Colors.black.withOpacity(0.5)),
              ),
            ),
          ),
          FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.86, end: 1).animate(spring),
              // The card is one still layer while it scales (nothing inside
              // animates until it lands), so the GPU can reuse its image.
              child: RepaintBoundary(child: page),
            ),
          ),
        ],
      );
    },
  );
}

class _SettingsPopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? doneLabel;
  final Widget child;

  const _SettingsPopup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.doneLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
            // Border and shadow sit outside; the fill comes from the `Material`
            // inside them. A `ListTile`/switch paints its ink on the nearest
            // `Material`, so a fill painted *above* it (a `DecoratedBox`
            // colour) would hide every splash — same split as `SectionCard`.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: context.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.32),
                    blurRadius: 34,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Material(
                color: context.surface,
                borderRadius: BorderRadius.circular(30),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Header(title: title, subtitle: subtitle, icon: icon),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          22,
                          20,
                          doneLabel == null ? 26 : 10,
                        ),
                        child: child,
                      ),
                    ),
                    if (doneLabel != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                        child: PrimaryButton(
                          label: doneLabel!,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The saffron band across the top: a badge, the title and a one-line hint.
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -46,
            child: _Glow(size: 160, color: Colors.white.withOpacity(0.15)),
          ),
          Positioned(
            left: -26,
            bottom: -56,
            child: _Glow(
              size: 130,
              color: AppColors.accentLight.withOpacity(0.32),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 12, 22),
            child: Row(
              children: [
                // Its own repaint boundary: the pop redraws only the badge,
                // not the whole card behind it.
                RepaintBoundary(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.36),
                          ),
                        ),
                        child: Icon(icon, size: 30, color: Colors.white),
                      ),
                    )
                    .animate(delay: kPopupTransition)
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1, 1),
                      duration: 560.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.3,
                          color: Colors.white.withOpacity(0.86),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
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
