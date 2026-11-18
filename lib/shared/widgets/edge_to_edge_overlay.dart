import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a full-bleed screen (no `AppBar` to own the status bar style) so
/// Android 15+/16's edge-to-edge default — a solid black status/nav bar —
/// doesn't obscure light content underneath. Icon brightness follows theme.
class EdgeToEdgeOverlay extends StatelessWidget {
  final Widget child;

  const EdgeToEdgeOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: child,
    );
  }
}
