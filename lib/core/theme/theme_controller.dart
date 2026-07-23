import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';

/// The user's chosen appearance (System/Light/Dark), persisted via
/// `LocalStorageService`, which already round-trips a nullable bool through
/// Hive — `null` means system, `true` dark, `false` light.
class ThemeModeController extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeModeController(this._storage) : super(_fromPreference(_storage.getThemePreference()));

  static ThemeMode _fromPreference(bool? isDark) {
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    switch (mode) {
      case ThemeMode.system:
        await _storage.clearThemePreference();
      case ThemeMode.dark:
        await _storage.saveThemePreference(true);
      case ThemeMode.light:
        await _storage.saveThemePreference(false);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref.watch(localStorageProvider));
});
