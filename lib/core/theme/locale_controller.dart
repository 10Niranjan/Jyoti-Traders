import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';

/// Supported app languages. English is the template/source locale; Hindi and
/// Marathi cover retailers more comfortable in those languages.
const supportedLocales = [Locale('en'), Locale('hi'), Locale('mr')];

/// The user's chosen app language, persisted via `LocalStorageService` —
/// same null-means-system shape as `ThemeModeController`.
class LocaleController extends StateNotifier<Locale?> {
  final LocalStorageService _storage;

  LocaleController(this._storage) : super(_fromPreference(_storage.getLanguagePreference()));

  static Locale? _fromPreference(String? code) => code == null ? null : Locale(code);

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _storage.clearLanguagePreference();
    } else {
      await _storage.saveLanguagePreference(locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(localStorageProvider));
});
