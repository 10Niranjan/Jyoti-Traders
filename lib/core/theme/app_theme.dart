import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// [AppTheme] manages the global light and dark theme configurations
/// for the application, ensuring high quality typography and layout styling.
///
/// Both themes come from one [_build] so a component theme can't be added to
/// one brightness and forgotten in the other — that drift is what left the
/// dark theme with unstyled buttons, a white divider and muted default text.
@immutable
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final textPrimary = dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = dark ? AppColors.borderDark : AppColors.borderLight;
    // One step off the surface: chips, switch tracks, tinted rows.
    final inset = dark ? AppColors.surfaceDark2 : AppColors.cardBorder;

    // Selected segments, chips and FABs read the *container* roles. They are
    // derived from `primary`/`secondary` when the scheme is constructed, so a
    // later `copyWith(primary: …)` leaves them at Material's stock purple/teal
    // — pass everything to the constructor instead, with a brand tint here.
    final tint = Color.alphaBlend(
      AppColors.primary.withOpacity(dark ? 0.24 : 0.14),
      surface,
    );
    // Brand-coloured text on the brand tint only reaches ~4:1; body text
    // colour clears 4.5:1 comfortably.
    final onTint = textPrimary;

    final scheme = dark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: tint,
            onPrimaryContainer: onTint,
            secondary: AppColors.accent,
            secondaryContainer: tint,
            onSecondaryContainer: onTint,
            surface: surface,
            onSurface: textPrimary,
            // Material's own subtitles, hints, labels and icons read this.
            onSurfaceVariant: textSecondary,
            outline: border,
            outlineVariant: border,
            surfaceContainerHighest: inset,
            error: AppColors.error,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: tint,
            onPrimaryContainer: onTint,
            secondary: AppColors.accent,
            secondaryContainer: tint,
            onSecondaryContainer: onTint,
            surface: surface,
            onSurface: textPrimary,
            onSurfaceVariant: textSecondary,
            outline: border,
            outlineVariant: border,
            surfaceContainerHighest: inset,
            error: AppColors.error,
          );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      // Horizontal slide on every platform — matches the Figma reference's
      // slide-in-from-right transition instead of each OS's own default
      // (Android's fade-through, in particular, reads nothing like it).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      // `bodyMedium` is what every un-coloured `Text` renders in, so it must
      // be the *primary* colour — it used to be the secondary one, which made
      // every title, price and total that forgot to set a colour look faded.
      // Deliberately muted text asks for `bodySmall`/`labelSmall` or
      // `context.textSecondary`.
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32.0,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16.0, color: textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 14.0, color: textPrimary),
        bodySmall: GoogleFonts.inter(fontSize: 12.0, color: textSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 11.0, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.surfaceDark2 : AppColors.surfaceLight,
        elevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      // Without these Material falls back to its own tonal-surface look:
      // a "Save" button with no fill, a white divider on a dark screen.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          disabledForegroundColor: Colors.white70,
          elevation: 0.0,
          shape: buttonShape,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: buttonShape,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: buttonShape,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      // FABs read `primaryContainer`, which is the soft brand tint above —
      // fine for a selected segment, too washed out for the main action.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1.0),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? AppColors.surfaceDark2 : AppColors.inkNavy,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 13.5,
        ),
        actionTextColor: AppColors.accentLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
