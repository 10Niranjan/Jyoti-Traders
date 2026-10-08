import '../../domain/entities/promo_banner_entity.dart';
import '../../domain/repositories/promo_banner_repository.dart';
import '../datasources/remote/promo_banner_remote_datasource.dart';

class PromoBannerRepositoryImpl implements PromoBannerRepository {
  final PromoBannerRemoteDatasource _remote;

  PromoBannerRepositoryImpl(this._remote);

  @override
  Stream<List<PromoBannerEntity>> watchBanners() => _remote.watchBanners();

  @override
  Future<void> saveBanners(List<PromoBannerEntity> banners) =>
      _remote.saveBanners(banners);
}
