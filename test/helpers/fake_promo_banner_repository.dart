import 'dart:async';

import 'package:traders_retailer/domain/entities/promo_banner_entity.dart';
import 'package:traders_retailer/domain/repositories/promo_banner_repository.dart';

/// In-memory stand-in for the `config/banners` document.
class FakePromoBannerRepository implements PromoBannerRepository {
  List<PromoBannerEntity> banners;
  final _controller = StreamController<List<PromoBannerEntity>>.broadcast();

  FakePromoBannerRepository([this.banners = const []]);

  @override
  Stream<List<PromoBannerEntity>> watchBanners() async* {
    yield banners;
    yield* _controller.stream;
  }

  @override
  Future<void> saveBanners(List<PromoBannerEntity> next) async {
    banners = next;
    _controller.add(next);
  }
}
