import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Cart bars currently mounted, newest last. The retailer shell keeps one
/// mounted all the time (hidden while the cart is empty) and pushed screens
/// such as the category page add their own on top, so a flight aims at the
/// newest one — the one the retailer is actually looking at.
final List<BuildContext> _cartBarTargets = [];

/// Wrap the cart bar so [flyToCart] knows where to land.
class CartFlightTarget extends StatefulWidget {
  final Widget child;

  const CartFlightTarget({super.key, required this.child});

  @override
  State<CartFlightTarget> createState() => _CartFlightTargetState();
}

class _CartFlightTargetState extends State<CartFlightTarget> {
  @override
  void initState() {
    super.initState();
    _cartBarTargets.add(context);
  }

  @override
  void dispose() {
    _cartBarTargets.remove(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// On-screen rectangle of [context]'s widget, or null if it isn't laid out.
Rect? globalRectOf(BuildContext context) {
  if (!context.mounted) return null;
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Where a flight should end: the newest cart bar, else the bottom of the
/// screen (the bar's usual spot) — e.g. for the very first add, before any
/// bar is on screen.
Offset _flightTarget(Size screen, EdgeInsets padding) {
  for (final context in _cartBarTargets.reversed) {
    final rect = globalRectOf(context);
    if (rect != null) return rect.center;
  }
  return Offset(screen.width / 2, screen.height - padding.bottom - 48);
}

/// Point [t] (0–1) along a quadratic curve from [from] to [to] that bows
/// upward, so the flight arcs instead of sliding in a straight line.
Offset flightPosition(Offset from, Offset to, double t) {
  final control = Offset(
    (from.dx + to.dx) / 2,
    (from.dy < to.dy ? from.dy : to.dy) - 110,
  );
  final inv = 1 - t;
  return from * (inv * inv) + control * (2 * inv * t) + to * (t * t);
}

/// Sends a small copy of the product photo arcing from [from] (where the
/// retailer tapped) to the cart bar, shrinking as it lands — the "it went in
/// the cart" feedback quick-commerce apps use. Purely visual: the cart itself
/// is already updated by the time this runs.
void flyToCart(
  OverlayState overlay, {
  required Rect from,
  required String imageUrl,
}) {
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Flyer(
      from: from,
      imageUrl: imageUrl,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _Flyer extends StatefulWidget {
  final Rect from;
  final String imageUrl;
  final VoidCallback onDone;

  const _Flyer({
    required this.from,
    required this.imageUrl,
    required this.onDone,
  });

  @override
  State<_Flyer> createState() => _FlyerState();
}

class _FlyerState extends State<_Flyer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 650),
          )
          ..forward().whenComplete(() {
            if (mounted) widget.onDone();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // The target is re-read every frame: on the very first add the cart
        // bar isn't on screen when the flight starts, but is by the time it
        // lands.
        final target = _flightTarget(media.size, media.padding);
        final t = Curves.easeInOut.transform(_controller.value);
        final position = flightPosition(widget.from.center, target, t);
        final size = lerpDouble(48, 20, t)!;
        final fade = _controller.value > 0.8
            ? 1 - (_controller.value - 0.8) / 0.2
            : 1.0;
        return Positioned(
          key: const ValueKey('cart-flyer'),
          left: position.dx - size / 2,
          top: position.dy - size / 2,
          width: size,
          height: size,
          child: IgnorePointer(
            child: Opacity(
              opacity: fade.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 8),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.imageUrl.isEmpty
                      ? const ColoredBox(
                          color: AppColors.primary,
                          child: Icon(
                            Icons.shopping_basket_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const ColoredBox(color: AppColors.primary),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
