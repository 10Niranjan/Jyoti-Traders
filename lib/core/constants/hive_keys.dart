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
  static const String languageCode = 'language_code';
  static const String simulatedDeliveryConfig = 'simulated_delivery_config';

  // user_cache
  static const String authToken = 'auth_token';
  static const String recentSearches = 'recent_searches';
  static const String currentUser = 'current_user';
  static const String simulatedUsers = 'simulated_users';
  static const String retailerSeedVersion = 'retailer_seed_version';

  // catalog_cache
  static const String simulatedCategories = 'simulated_categories';
  static const String simulatedProducts = 'simulated_products';
  static const String cachedProductCatalog = 'cached_product_catalog';
  static const String catalogSeedVersion = 'catalog_seed_version';

  // orders_cache
  static const String simulatedOrders = 'simulated_orders';
  static const String orderSeedVersion = 'order_seed_version';

  // cart_box
  static const String cartItems = 'cart_items';
  static const String wishlistItems = 'wishlist_items';

  // notifications_cache
  static const String notificationItems = 'notification_items';
  static const String notificationSeedVersion = 'notification_seed_version';
  static const String broadcastMessages = 'broadcast_messages';
  static const String seenBroadcastIds = 'seen_broadcast_ids';
}
