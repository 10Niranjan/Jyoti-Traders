import 'package:flutter/material.dart';

/// Wraps [child] in an `InkWell` that also scales down slightly while
/// pressed — the "tap lands" feedback Skiper/Vengeance-style component
/// libraries use, on top of the ripple this app's cards already show.
/// `AnimatedScale` (stdlib) is enough for a two-state press toggle; no need
/// for `flutter_animate`'s heavier timeline API here.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  const PressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          _setPressed(false);
          widget.onTap();
        },
        child: widget.child,
      ),
    );
  }
}
