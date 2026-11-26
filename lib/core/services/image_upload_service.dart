import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../constants/storage_paths.dart';
import '../network/firebase_mode.dart';
import '../utils/app_logger.dart';

/// Uploads product images, category icons, profile photos and UPI payment
/// screenshots. Where the file goes, in order:
///
/// 1. **Cloudinary** when [AppConstants.kCloudinaryCloudName] and
///    [AppConstants.kCloudinaryUploadPreset] are set — free, no card, and it
///    resizes/compresses for us. Uses an unsigned preset, so there is no
///    secret in the app and no overwrite or delete (an edited photo uploads
///    as a new image; the old one is simply left behind).
/// 2. **Firebase Storage** when a live project with Storage is configured.
/// 3. **Simulation mode** otherwise: the picked file's local path is
///    returned as the "URL". Admin screens render that with `Image.file`, and
///    retailer-side `CachedNetworkImage` widgets fall back to their
///    placeholder icon via `errorWidget`.
class ImageUploadService {
  final FirebaseStorage? _storage;
  final bool _useMock;
  final String _cloudName;
  final String _preset;
  final String _cloudinaryHost;

  ImageUploadService._(
    this._storage,
    this._useMock,
    this._cloudName,
    this._preset,
    this._cloudinaryHost,
  );

  factory ImageUploadService({
    FirebaseStorage? storage,
    String cloudName = AppConstants.kCloudinaryCloudName,
    String preset = AppConstants.kCloudinaryUploadPreset,
    String cloudinaryHost = 'https://api.cloudinary.com',
  }) {
    try {
      final instance = storage ?? FirebaseStorage.instance;
      return ImageUploadService._(
        instance,
        isFirebasePlaceholder(Firebase.app()),
        cloudName,
        preset,
        cloudinaryHost,
      );
    } catch (e) {
      logWarning(
        'ImageUploadService: Firebase Storage unavailable, using simulation mode',
        e,
      );
      return ImageUploadService._(
        null,
        true,
        cloudName,
        preset,
        cloudinaryHost,
      );
    }
  }

  bool get _useCloudinary => _cloudName.isNotEmpty && _preset.isNotEmpty;

  /// Returns the image's URL, or the local file path in simulation mode.
  Future<String> _upload({
    required String folder,
    required String storagePath,
    required String localFilePath,
  }) async {
    if (_useCloudinary) {
      return _uploadToCloudinary(folder, localFilePath);
    }
    if (_useMock || _storage == null) return localFilePath;
    final ref = _storage.ref(storagePath);
    await ref.putFile(File(localFilePath));
    return ref.getDownloadURL();
  }

  /// Hand-rolled multipart POST (dart:io only) — not worth a new package for
  /// one request. Throws on any non-200 so callers show their normal upload
  /// error instead of saving a broken URL.
  Future<String> _uploadToCloudinary(
    String folder,
    String localFilePath,
  ) async {
    final boundary = 'jt${DateTime.now().microsecondsSinceEpoch}';
    final bytes = await File(localFilePath).readAsBytes();
    final body = BytesBuilder()
      ..add(
        utf8.encode(
          '--$boundary\r\nContent-Disposition: form-data; name="upload_preset"'
          '\r\n\r\n$_preset\r\n'
          '--$boundary\r\nContent-Disposition: form-data; name="folder"'
          '\r\n\r\n$folder\r\n'
          '--$boundary\r\nContent-Disposition: form-data; name="file"; '
          'filename="upload.jpg"\r\nContent-Type: application/octet-stream'
          '\r\n\r\n',
        ),
      )
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--\r\n'));
    final payload = body.takeBytes();

    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('$_cloudinaryHost/v1_1/$_cloudName/image/upload'),
      );
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );
      request.contentLength = payload.length;
      request.add(payload);
      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw HttpException(
          'Cloudinary upload failed (${response.statusCode}): $text',
        );
      }
      return (jsonDecode(text) as Map<String, dynamic>)['secure_url'] as String;
    } finally {
      client.close();
    }
  }

  Future<String> uploadProductImage({
    required String productId,
    required String localFilePath,
  }) => _upload(
    folder: StoragePaths.productImages,
    storagePath: StoragePaths.productImage(productId),
    localFilePath: localFilePath,
  );

  /// Best-effort cleanup when a product is deleted. A missing object is not
  /// an error. Cloudinary images are left in place (unsigned presets can't
  /// delete) — they cost nothing on the free plan.
  Future<void> deleteProductImage(String productId) async {
    if (_useCloudinary || _useMock || _storage == null) return;
    try {
      await _storage.ref(StoragePaths.productImage(productId)).delete();
    } catch (e) {
      logWarning(
        'ImageUploadService: no stored image to delete for $productId',
        e,
      );
    }
  }

  Future<String> uploadCategoryIcon({
    required String categoryId,
    required String localFilePath,
  }) => _upload(
    folder: StoragePaths.categoryIcons,
    storagePath: StoragePaths.categoryIcon(categoryId),
    localFilePath: localFilePath,
  );

  Future<void> deleteCategoryIcon(String categoryId) async {
    if (_useCloudinary || _useMock || _storage == null) return;
    try {
      await _storage.ref(StoragePaths.categoryIcon(categoryId)).delete();
    } catch (e) {
      logWarning(
        'ImageUploadService: no stored icon to delete for $categoryId',
        e,
      );
    }
  }

  /// A retailer's optional UPI payment screenshot.
  // ponytail: on Cloudinary the URL itself is the only lock — a random,
  // unguessable id, folder listing is off (401), and the link lives only in
  // the order doc, which firestore.rules lets just the owner and admin read.
  // A forwarded link still opens it; move to Firebase Storage (rule-checked
  // on every view) if the shop goes on Blaze anyway.
  Future<String> uploadPaymentScreenshot({
    required String orderId,
    required String localFilePath,
  }) => _upload(
    folder: StoragePaths.paymentScreenshots,
    storagePath: StoragePaths.paymentScreenshot(orderId),
    localFilePath: localFilePath,
  );

  /// A retailer or admin's profile photo.
  Future<String> uploadProfilePhoto({
    required String uid,
    required String localFilePath,
  }) => _upload(
    folder: StoragePaths.profilePhotos,
    storagePath: StoragePaths.profilePhoto(uid),
    localFilePath: localFilePath,
  );
}

final imageUploadServiceProvider = Provider<ImageUploadService>(
  (ref) => ImageUploadService(),
);
