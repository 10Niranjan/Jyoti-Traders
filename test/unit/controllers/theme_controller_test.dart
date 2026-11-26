import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/theme_controller.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';

/// Overrides just the theme-related methods so this test never touches a
/// real Hive box — `LocalStorageService`'s other members are untouched by
/// `ThemeModeController`.
class FakeLocalStorageService extends LocalStorageService {
  String? stored;
  FakeLocalStorageService([this.stored]);

  @override
  String? getThemeMode() => stored;

  @override
  Future<void> saveThemeMode(String mode) async => stored = mode;
}

void main() {
  test('defaults to light when nothing is stored', () {
    final controller = ThemeModeController(FakeLocalStorageService());
    expect(controller.state, ThemeMode.light);
  });

  test('loads each saved mode', () {
    for (final mode in ThemeMode.values) {
      final controller = ThemeModeController(
        FakeLocalStorageService(mode.name),
      );
      expect(controller.state, mode);
    }
  });

  test('an unknown saved value falls back to light', () {
    final controller = ThemeModeController(FakeLocalStorageService('purple'));
    expect(controller.state, ThemeMode.light);
  });

  test('setThemeMode updates state and persists the mode', () async {
    final storage = FakeLocalStorageService();
    final controller = ThemeModeController(storage);

    await controller.setThemeMode(ThemeMode.dark);

    expect(controller.state, ThemeMode.dark);
    expect(storage.stored, 'dark');
  });

  // The bug this guards: "System" used to clear the saved value, which then
  // loaded back as Light on the next launch.
  test('System survives a restart', () async {
    final storage = FakeLocalStorageService('dark');
    await ThemeModeController(storage).setThemeMode(ThemeMode.system);

    expect(ThemeModeController(storage).state, ThemeMode.system);
  });
}
