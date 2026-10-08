import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _secureStorage = FlutterSecureStorage();
const _keyStorageKey = 'hive_encryption_key';

/// Opens [boxName] encrypted at rest with an AES key held in the OS
/// keystore (Android EncryptedSharedPreferences / iOS Keychain, via
/// flutter_secure_storage) rather than on Hive's own disk file — for boxes
/// that cache PII (bank details, GST, phone, address) so a plaintext file
/// isn't sitting in app-private storage.
Future<Box> openEncryptedBox(String boxName) async {
  var keyString = await _secureStorage.read(key: _keyStorageKey);
  if (keyString == null) {
    keyString = base64UrlEncode(Hive.generateSecureKey());
    await _secureStorage.write(key: _keyStorageKey, value: keyString);
  }
  final cipher = HiveAesCipher(base64Url.decode(keyString));

  try {
    return await Hive.openBox(boxName, encryptionCipher: cipher);
  } catch (_) {
    // Box already exists on disk unencrypted (or under a since-lost key) —
    // undecodable with this cipher. It's a cache, safe to drop and rebuild
    // (re-synced from Firestore, or re-populated on next simulated sign-up).
    await Hive.deleteBoxFromDisk(boxName);
    return await Hive.openBox(boxName, encryptionCipher: cipher);
  }
}
