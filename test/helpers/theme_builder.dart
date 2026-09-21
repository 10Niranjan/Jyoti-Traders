import 'dart:async';

import 'package:flutter/material.dart';
import 'package:traders_retailer/core/theme/app_theme.dart';

/// Builds the real [AppTheme] for a test.
///
/// `AppTheme` calls `GoogleFonts.inter`, which starts a font download the
/// moment it is built. The test binding answers every HTTP request with a
/// 400, and google_fonts surfaces that as an uncaught async error — which the
/// runner then pins on whichever test happens to be running. Building the
/// theme in its own guarded zone keeps those expected font failures local;
/// the colours and component themes under test don't depend on the font.
ThemeData buildTheme({required bool dark}) {
  final theme = runZonedGuarded(
    () => dark ? AppTheme.darkTheme : AppTheme.lightTheme,
    (_, _) {},
  );
  return theme ?? (throw StateError('AppTheme threw while building'));
}
