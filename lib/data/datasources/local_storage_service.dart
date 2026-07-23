import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_keys.dart';

/// Provider for accessing the local storage service globally
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// A robust wrapper around Hive for managing local on-device storage.
/// Handles caching of auth tokens, user preferences, and app settings.
class LocalStorageService {
  // Lazy box getters to ensure they are accessed safely
  Box get _settingsBox => Hive.box(HiveBoxes.settingsCache);
  Box get _userBox => Hive.box(HiveBoxes.userCache);

  // ==========================================
  // Auth Token Management
  // ==========================================
  
  Future<void> saveAuthToken(String token) async {
    await _userBox.put(HiveKeys.authToken, token);
  }

  String? getAuthToken() {
    return _userBox.get(HiveKeys.authToken) as String?;
  }

  Future<void> clearAuthToken() async {
    await _userBox.delete(HiveKeys.authToken);
  }

  bool get isAuthenticated => getAuthToken() != null;

  // ==========================================
  // App Settings & Preferences
  // ==========================================

  /// Saves the user's theme preference (true for dark mode, false for light)
  Future<void> saveThemePreference(bool isDarkMode) async {
    await _settingsBox.put(HiveKeys.themeMode, isDarkMode);
  }

  /// Returns the saved theme preference, defaults to system (null) if not set
  bool? getThemePreference() {
    return _settingsBox.get(HiveKeys.themeMode) as bool?;
  }

  /// Resets to following the OS theme (used when the user picks "System").
  Future<void> clearThemePreference() async {
    await _settingsBox.delete(HiveKeys.themeMode);
  }

  /// Checks if the app is launched for the first time (to show onboarding)
  bool isFirstLaunch() {
    return _settingsBox.get(HiveKeys.isFirstLaunch, defaultValue: true) as bool;
  }

  /// Marks the onboarding as completed
  Future<void> setFirstLaunchCompleted() async {
    await _settingsBox.put(HiveKeys.isFirstLaunch, false);
  }

  // ==========================================
  // Search History
  // ==========================================

  List<String> getRecentSearches() {
    final List<dynamic>? searches = _userBox.get(HiveKeys.recentSearches);
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
    
    await _userBox.put(HiveKeys.recentSearches, searches);
  }

  Future<void> clearRecentSearches() async {
    await _userBox.delete(HiveKeys.recentSearches);
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
