import '../entities/promo_banner_entity.dart';

abstract class PromoBannerRepository {
  /// Every banner, live or not, in display order.
  Stream<List<PromoBannerEntity>> watchBanners();

  /// Replaces the whole list — banners are a handful of items edited by one
  /// admin, so a single ordered write is simpler than per-item CRUD.
  Future<void> saveBanners(List<PromoBannerEntity> banners);
}
