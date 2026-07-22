import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/usecases/user/approve_user_usecase.dart';
import '../../../domain/usecases/user/reject_user_usecase.dart';

/// Tracks which retailer's card is mid-action so only that card shows a
/// spinner, instead of freezing the whole queue on every approve/reject.
final approvalInFlightUidProvider = StateProvider.autoDispose<String?>((ref) => null);

/// `AsyncValue<void>` surfaces the last action's error (if any) via
/// `.hasError`/`.error` — the same pattern as `CheckoutController`.
class ApprovalController extends StateNotifier<AsyncValue<void>> {
  final ApproveUserUseCase _approveUseCase;
  final RejectUserUseCase _rejectUseCase;

  ApprovalController(this._approveUseCase, this._rejectUseCase) : super(const AsyncValue.data(null));

  Future<void> approve(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _approveUseCase(uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reject(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _rejectUseCase(uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final approvalControllerProvider = StateNotifierProvider.autoDispose<ApprovalController, AsyncValue<void>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return ApprovalController(ApproveUserUseCase(userRepository), RejectUserUseCase(userRepository));
});
