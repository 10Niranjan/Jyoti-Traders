import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for accessing the local storage service globally
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// A robust wrapper around Hive for managing local on-device storage.
/// Handles caching of auth tokens, user preferences, and app settings.
class LocalStorageService {
  // Box Names (initialized in main.dart)
  static const String _settingsBoxName = 'settings_cache';
  static const String _userBoxName = 'user_cache';

  // Storage Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyRecentSearches = 'recent_searches';

  // Lazy box getters to ensure they are accessed safely
  Box get _settingsBox => Hive.box(_settingsBoxName);
  Box get _userBox => Hive.box(_userBoxName);

  // ==========================================
  // Auth Token Management
  // ==========================================
  
  Future<void> saveAuthToken(String token) async {
    await _userBox.put(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return _userBox.get(_keyAuthToken) as String?;
  }

  Future<void> clearAuthToken() async {
    await _userBox.delete(_keyAuthToken);
  }

  bool get isAuthenticated => getAuthToken() != null;

  // ==========================================
  // App Settings & Preferences
  // ==========================================

  /// Saves the user's theme preference (true for dark mode, false for light)
  Future<void> saveThemePreference(bool isDarkMode) async {
    await _settingsBox.put(_keyThemeMode, isDarkMode);
  }

  /// Returns the saved theme preference, defaults to system (null) if not set
  bool? getThemePreference() {
    return _settingsBox.get(_keyThemeMode) as bool?;
  }

  /// Checks if the app is launched for the first time (to show onboarding)
  bool isFirstLaunch() {
    return _settingsBox.get(_keyIsFirstLaunch, defaultValue: true) as bool;
  }

  /// Marks the onboarding as completed
  Future<void> setFirstLaunchCompleted() async {
    await _settingsBox.put(_keyIsFirstLaunch, false);
  }

  // ==========================================
  // Search History
  // ==========================================

  List<String> getRecentSearches() {
    final List<dynamic>? searches = _userBox.get(_keyRecentSearches);
    if (searches == null) return [];
    return searches.cast<String>();
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final searches = getRecentSearches();
    // Remove if it already exists to move it to the top
    searches.remove(query);
    // Add to the beginning
    searches.insert(0, query);
    
    // Keep only the last 10 searches
    if (searches.length > 10) {
      searches.removeLast();
    }
    
    await _userBox.put(_keyRecentSearches, searches);
  }

  Future<void> clearRecentSearches() async {
    await _userBox.delete(_keyRecentSearches);
  }

  // ==========================================
  // Global Clear
  // ==========================================

  /// Completely clears all user data (used on Logout)
  Future<void> clearAllUserData() async {
    await _userBox.clear();
    // Note: We usually don't clear settingsBox on logout so theme prefs remain
  }
}
