import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/theme_controller.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';

/// Overrides just the theme-related methods so this test never touches a
/// real Hive box — `LocalStorageService`'s other members are untouched by
/// `ThemeModeController`.
class FakeLocalStorageService extends LocalStorageService {
  bool? stored;
  FakeLocalStorageService([this.stored]);

  @override
  bool? getThemePreference() => stored;

  @override
  Future<void> saveThemePreference(bool isDarkMode) async => stored = isDarkMode;

  @override
  Future<void> clearThemePreference() async => stored = null;
}

void main() {
  test('defaults to light when nothing is stored', () {
    final controller = ThemeModeController(FakeLocalStorageService());
    expect(controller.state, ThemeMode.light);
  });

  test('loads dark mode from a stored true preference', () {
    final controller = ThemeModeController(FakeLocalStorageService(true));
    expect(controller.state, ThemeMode.dark);
  });

  test('loads light mode from a stored false preference', () {
    final controller = ThemeModeController(FakeLocalStorageService(false));
    expect(controller.state, ThemeMode.light);
  });

  test('setThemeMode(dark) updates state and persists true', () async {
    final storage = FakeLocalStorageService();
    final controller = ThemeModeController(storage);

    await controller.setThemeMode(ThemeMode.dark);

    expect(controller.state, ThemeMode.dark);
    expect(storage.stored, isTrue);
  });

  test('setThemeMode(light) updates state and persists false', () async {
    final storage = FakeLocalStorageService();
    final controller = ThemeModeController(storage);

    await controller.setThemeMode(ThemeMode.light);

    expect(controller.state, ThemeMode.light);
    expect(storage.stored, isFalse);
  });

  test('setThemeMode(system) clears the persisted preference', () async {
    final storage = FakeLocalStorageService(true);
    final controller = ThemeModeController(storage);

    await controller.setThemeMode(ThemeMode.system);

    expect(controller.state, ThemeMode.system);
    expect(storage.stored, isNull);
  });
}
