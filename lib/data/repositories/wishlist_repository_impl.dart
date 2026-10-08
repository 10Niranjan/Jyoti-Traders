import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/local/wishlist_local_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDatasource _local;

  WishlistRepositoryImpl(this._local);

  @override
  Stream<Set<String>> watchWishlist() => _local.watchWishlist();

  @override
  Future<void> toggle(String productId) => _local.toggle(productId);
}
