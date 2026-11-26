import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../../domain/entities/notification_preferences_entity.dart';

/// `AsyncValue<void>` — loading/success/error over the profile update call,
/// same standard pattern as `CheckoutController`.
class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ProfileController(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? businessName,
    AddressEntity? address,
    List<AddressEntity>? savedAddresses,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(authRepositoryProvider).updateProfile(
            uid: uid,
            name: name,
            phone: phone,
            businessName: businessName,
            address: address,
            savedAddresses: savedAddresses,
            gstNumber: gstNumber,
            bankDetails: bankDetails,
            businessHours: businessHours,
            notificationPreferences: notificationPreferences,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Deletes the account. Returns whether it worked; the error is left in
  /// [state] for the caller to show. On success the auth stream signs the user
  /// out, which tears down the screen (and this autoDispose controller) before
  /// the await returns — hence the [mounted] guards.
  Future<bool> deleteAccount({
    required String uid,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _ref
          .read(authRepositoryProvider)
          .deleteAccount(uid: uid, password: password);
      if (mounted) state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Uploads the freshly-picked photo first so the resulting URL (or, in
  /// simulation mode, local path) is what gets persisted — same pattern as
  /// `AdminProductController.create`'s image handling.
  Future<void> updatePhoto({required String uid, required String localFilePath}) async {
    state = const AsyncValue.loading();
    try {
      final photoUrl = await _ref
          .read(imageUploadServiceProvider)
          .uploadProfilePhoto(uid: uid, localFilePath: localFilePath);
      await _ref.read(authRepositoryProvider).updateProfile(uid: uid, photoUrl: photoUrl);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileControllerProvider = StateNotifierProvider.autoDispose<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref);
});
