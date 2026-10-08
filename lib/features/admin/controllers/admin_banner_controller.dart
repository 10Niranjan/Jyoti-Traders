import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/promo_banner_entity.dart';

/// Every banner, live or not — what the admin's Banners screen lists.
final promoBannersProvider =
    StreamProvider.autoDispose<List<PromoBannerEntity>>((ref) {
      return ref.watch(promoBannerRepositoryProvider).watchBanners();
    });

/// Banners a retailer should see right now: switched on and not past their
/// end date.
///
/// ponytail: "now" is read when this provider recomputes (a banner edit, or
/// the next app start), not on a timer — a banner whose end date passes while
/// Home is already open lingers until then. Add a periodic ref.invalidate if
/// that ever matters.
final activePromoBannersProvider =
    Provider.autoDispose<List<PromoBannerEntity>>((ref) {
      final all = ref.watch(promoBannersProvider).valueOrNull ?? const [];
      final now = DateTime.now();
      return all.where((b) => b.isLiveAt(now)).toList();
    });

/// Write side, admin-only. Each call reads the current list, applies one
/// change and writes it back — a single admin edits a handful of banners, so
/// last-write-wins is fine here.
class AdminBannerController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AdminBannerController(this._ref) : super(const AsyncValue.data(null));

  /// Adds a new banner at the front (the newest offer leads the carousel) or
  /// replaces the existing one with the same id in place.
  Future<bool> save(PromoBannerEntity banner) => _mutate((list) {
    final i = list.indexWhere((b) => b.id == banner.id);
    return i == -1 ? [banner, ...list] : ([...list]..[i] = banner);
  });

  Future<bool> delete(String id) =>
      _mutate((list) => list.where((b) => b.id != id).toList());

  Future<bool> setActive(String id, bool isActive) => _mutate(
    (list) => [
      for (final b in list) b.id == id ? b.copyWith(isActive: isActive) : b,
    ],
  );

  Future<bool> _mutate(
    List<PromoBannerEntity> Function(List<PromoBannerEntity>) change,
  ) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(promoBannerRepositoryProvider);
      final current = await repo.watchBanners().first;
      await repo.saveBanners(change(current));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminBannerControllerProvider =
    StateNotifierProvider.autoDispose<AdminBannerController, AsyncValue<void>>((
      ref,
    ) {
      return AdminBannerController(ref);
    });
