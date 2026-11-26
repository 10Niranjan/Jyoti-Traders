import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';

/// The user's chosen appearance (System/Light/Dark), persisted via
/// `LocalStorageService` by name. Nothing saved yet means Light (the brand's
/// default look); "System" is saved too, so it survives a restart.
class ThemeModeController extends StateNotifier<ThemeMode> {
  final LocalStorageService _storage;

  ThemeModeController(this._storage)
    : super(
        ThemeMode.values.asNameMap()[_storage.getThemeMode()] ??
            ThemeMode.light,
      );

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController(ref.watch(localStorageProvider));
  },
);
