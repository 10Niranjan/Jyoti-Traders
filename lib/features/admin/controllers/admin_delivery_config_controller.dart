import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/delivery_config_entity.dart';

/// Live delivery-pricing config — read by `CheckoutScreen` to price
/// delivery, and by the admin's `DeliverySettingsScreen` to display and
/// edit it. Ownership (the write side) is admin-only, via
/// [adminDeliveryConfigControllerProvider] below.
final deliveryConfigProvider = StreamProvider.autoDispose<DeliveryConfigEntity>((ref) {
  return ref.watch(deliveryConfigRepositoryProvider).watchConfig();
});

class AdminDeliveryConfigController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AdminDeliveryConfigController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> updateConfig(DeliveryConfigEntity config) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(deliveryConfigRepositoryProvider).updateConfig(config);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminDeliveryConfigControllerProvider =
    StateNotifierProvider.autoDispose<AdminDeliveryConfigController, AsyncValue<void>>((ref) {
  return AdminDeliveryConfigController(ref);
});
