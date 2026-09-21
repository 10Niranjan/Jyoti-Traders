import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/business_profile_entity.dart';

/// The owner's legal identity (`config/business`). Read by the admin's editor
/// and by every invoice build — retailers included, since their phone builds
/// the PDF too.
final businessProfileProvider =
    StreamProvider.autoDispose<BusinessProfileEntity>((ref) {
      return ref.watch(businessProfileRepositoryProvider).watchProfile();
    });

/// `AsyncValue<void>` over the save, same shape as `ProfileController`.
/// Deliberately not autoDispose: the editor sheet awaits it while nothing else
/// is watching, and an autoDispose provider would be torn down mid-await.
class BusinessProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BusinessProfileController(this._ref) : super(const AsyncValue.data(null));

  Future<void> save(BusinessProfileEntity profile) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(businessProfileRepositoryProvider).saveProfile(profile);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final businessProfileControllerProvider =
    StateNotifierProvider<BusinessProfileController, AsyncValue<void>>(
      (ref) => BusinessProfileController(ref),
    );
