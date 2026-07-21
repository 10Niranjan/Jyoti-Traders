import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/entities/address_entity.dart';

/// `AsyncValue<void>` — loading/success/error over the profile update call,
/// same standard pattern as `CheckoutController`.
class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProfileController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String uid,
    AddressEntity? address,
    String? gstNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(authRepositoryProvider).updateProfile(uid: uid, address: address, gstNumber: gstNumber);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileControllerProvider = StateNotifierProvider.autoDispose<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref);
});
