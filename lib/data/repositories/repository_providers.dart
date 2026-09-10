import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_keys.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/delivery_config_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/broadcast_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/auth_state.dart';
import '../datasources/local/broadcast_local_datasource.dart';
import '../datasources/local/cart_local_datasource.dart';
import '../datasources/local/notification_local_datasource.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/local/wishlist_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../datasources/remote/delivery_config_remote_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../datasources/remote/user_remote_datasource.dart';
import 'broadcast_repository_impl.dart';
import 'category_repository_impl.dart';
import 'cart_repository_impl.dart';
import 'delivery_config_repository_impl.dart';
import 'notification_repository_impl.dart';
import 'order_repository_impl.dart';
import 'product_repository_impl.dart';
import 'user_repository_impl.dart';
import 'wishlist_repository_impl.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final catalogBox = Hive.box(HiveBoxes.catalogCache);
  return CategoryRepositoryImpl(CategoryRemoteDatasource(catalogBox: catalogBox));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final catalogBox = Hive.box(HiveBoxes.catalogCache);
  return ProductRepositoryImpl(
    ProductRemoteDatasource(catalogBox: catalogBox),
    ProductLocalDatasource(catalogBox: catalogBox),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final ordersBox = Hive.box(HiveBoxes.ordersCache);
  return OrderRepositoryImpl(OrderRemoteDatasource(ordersBox: ordersBox));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final userCacheBox = Hive.box(HiveBoxes.userCache);
  return UserRepositoryImpl(UserRemoteDatasource(userCacheBox: userCacheBox));
});

/// Watches auth state so a different account signing in on the same device
/// gets a fresh [CartLocalDatasource] keyed to its own uid, instead of
/// inheriting whatever the previous account left in the shared cart box.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final authState = ref.watch(authControllerProvider);
  final uid = switch (authState) {
    AuthenticatedAdmin(user: final u) => u.uid,
    AuthenticatedCustomer(user: final u) => u.uid,
    PendingApproval(user: final u) => u.uid,
    _ => 'signed_out',
  };
  final cartBox = Hive.box(HiveBoxes.cartBox);
  return CartRepositoryImpl(CartLocalDatasource(cartBox: cartBox, uid: uid));
});

/// Same auth-uid-scoping reason as [cartRepositoryProvider] above.
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final authState = ref.watch(authControllerProvider);
  final uid = switch (authState) {
    AuthenticatedAdmin(user: final u) => u.uid,
    AuthenticatedCustomer(user: final u) => u.uid,
    PendingApproval(user: final u) => u.uid,
    _ => 'signed_out',
  };
  final cartBox = Hive.box(HiveBoxes.cartBox);
  return WishlistRepositoryImpl(WishlistLocalDatasource(box: cartBox, uid: uid));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final box = Hive.box(HiveBoxes.notificationsCache);
  return NotificationRepositoryImpl(NotificationLocalDatasource(box: box));
});

final broadcastRepositoryProvider = Provider<BroadcastRepository>((ref) {
  final box = Hive.box(HiveBoxes.notificationsCache);
  return BroadcastRepositoryImpl(BroadcastLocalDatasource(box: box));
});

final deliveryConfigRepositoryProvider = Provider<DeliveryConfigRepository>((ref) {
  final settingsBox = Hive.box(HiveBoxes.settingsCache);
  return DeliveryConfigRepositoryImpl(DeliveryConfigRemoteDatasource(settingsBox: settingsBox));
});
