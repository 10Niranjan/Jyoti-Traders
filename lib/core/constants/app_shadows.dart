import 'package:flutter/material.dart';

/// Shared box-shadow presets — every white/surface card in the app should
/// use [AppShadows.card] instead of inventing its own `BoxShadow` so the
/// whole app reads as one visual system (mirrors the mockup's `shadow-sm`).
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 3.0, offset: Offset(0, 1)),
  ];
}
