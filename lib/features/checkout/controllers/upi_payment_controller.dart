import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/usecases/order/record_payment_claim_usecase.dart';

/// The retailer's "I have paid" confirmation on the UPI payment screen —
/// optionally uploads a payment screenshot first, then records the claim.
class UpiPaymentController extends StateNotifier<AsyncValue<void>> {
  final RecordPaymentClaimUseCase _recordClaimUseCase;
  final ImageUploadService _imageUploadService;

  UpiPaymentController(this._recordClaimUseCase, this._imageUploadService) : super(const AsyncValue.data(null));

  Future<bool> confirmPayment(String orderId, {String? localScreenshotPath}) async {
    state = const AsyncValue.loading();
    try {
      String? screenshotUrl;
      if (localScreenshotPath != null) {
        screenshotUrl = await _imageUploadService.uploadPaymentScreenshot(
          orderId: orderId,
          localFilePath: localScreenshotPath,
        );
      }
      await _recordClaimUseCase(orderId, screenshotUrl: screenshotUrl);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final upiPaymentControllerProvider = StateNotifierProvider.autoDispose<UpiPaymentController, AsyncValue<void>>((ref) {
  return UpiPaymentController(
    RecordPaymentClaimUseCase(ref.watch(orderRepositoryProvider)),
    ref.watch(imageUploadServiceProvider),
  );
});
