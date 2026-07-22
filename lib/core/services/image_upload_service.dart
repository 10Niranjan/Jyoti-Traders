import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../constants/storage_paths.dart';
import '../network/firebase_mode.dart';

/// Uploads product images to Firebase Storage, with the same
/// simulation-mode fallback every other Firebase-touching service in this
/// app uses (see [isFirebasePlaceholder]).
///
/// In simulation mode there is no bucket to upload to, so the picked file's
/// **local path** is returned as the "URL". Admin screens render that with
/// `Image.file`, and retailer-side `CachedNetworkImage` widgets fall back to
/// their placeholder icon via `errorWidget` — so nothing crashes, and the
/// moment a real Firebase project is configured this starts returning real
/// download URLs with no call-site changes.
class ImageUploadService {
  final FirebaseStorage? _storage;
  final bool _useMock;

  ImageUploadService._(this._storage, this._useMock);

  factory ImageUploadService({FirebaseStorage? storage}) {
    try {
      final instance = storage ?? FirebaseStorage.instance;
      return ImageUploadService._(instance, isFirebasePlaceholder(Firebase.app()));
    } catch (e) {
      debugPrint('ImageUploadService: Firebase Storage unavailable, using simulation mode: $e');
      return ImageUploadService._(null, true);
    }
  }

  /// Returns the uploaded image's download URL, or the local file path when
  /// running in simulation mode.
  Future<String> uploadProductImage({required String productId, required String localFilePath}) async {
    if (_useMock || _storage == null) {
      return localFilePath;
    }
    final ref = _storage.ref(StoragePaths.productImage(productId));
    await ref.putFile(File(localFilePath));
    return ref.getDownloadURL();
  }

  /// Best-effort cleanup when a product is deleted. A missing object is not
  /// an error — products created before image upload existed, or in
  /// simulation mode, have no stored object to remove.
  Future<void> deleteProductImage(String productId) async {
    if (_useMock || _storage == null) return;
    try {
      await _storage.ref(StoragePaths.productImage(productId)).delete();
    } catch (e) {
      debugPrint('ImageUploadService: no stored image to delete for $productId ($e)');
    }
  }
}
