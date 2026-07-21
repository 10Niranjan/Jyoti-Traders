import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_keys.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/cart_local_datasource.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../datasources/remote/user_remote_datasource.dart';
import 'category_repository_impl.dart';
import 'cart_repository_impl.dart';
import 'order_repository_impl.dart';
import 'product_repository_impl.dart';
import 'user_repository_impl.dart';

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

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final cartBox = Hive.box(HiveBoxes.cartBox);
  return CartRepositoryImpl(CartLocalDatasource(cartBox: cartBox));
});
