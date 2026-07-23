/// Hive box and key name constants — single source of truth for local storage.
class HiveBoxes {
  HiveBoxes._();

  static const String settingsCache = 'settings_cache';
  static const String userCache = 'user_cache';
  static const String catalogCache = 'catalog_cache';
  static const String ordersCache = 'orders_cache';
  static const String cartBox = 'cart_box';
  static const String notificationsCache = 'notifications_cache';
}

class HiveKeys {
  HiveKeys._();

  // settings_cache
  static const String themeMode = 'theme_mode';
  static const String isFirstLaunch = 'is_first_launch';

  // user_cache
  static const String authToken = 'auth_token';
  static const String recentSearches = 'recent_searches';
  static const String currentUser = 'current_user';
  static const String simulatedUsers = 'simulated_users';

  // catalog_cache
  static const String simulatedCategories = 'simulated_categories';
  static const String simulatedProducts = 'simulated_products';
  static const String cachedProductCatalog = 'cached_product_catalog';

  // orders_cache
  static const String simulatedOrders = 'simulated_orders';

  // cart_box
  static const String cartItems = 'cart_items';

  // notifications_cache
  static const String notificationItems = 'notification_items';
}
