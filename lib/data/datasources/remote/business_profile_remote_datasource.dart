import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/business_profile_entity.dart';

/// Firestore access for the single `config/business` document, with a Hive
/// simulation fallback — the same dual-mode shape as
/// `DeliveryConfigRemoteDatasource`.
class BusinessProfileRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _settingsBox;
  bool _useMock = false;
  final _controller = StreamController<BusinessProfileEntity>.broadcast();

  BusinessProfileRemoteDatasource({
    FirebaseFirestore? firestore,
    required Box settingsBox,
  }) : _settingsBox = settingsBox {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning(
        'BusinessProfileRemoteDatasource: Firestore unavailable, using simulation mode',
        e,
      );
    }
  }

  DocumentReference<Map<String, dynamic>> get _doc => _firestore!
      .collection(FirestorePaths.config)
      .doc(FirestorePaths.businessProfileDoc);

  static BusinessProfileEntity _fromMap(Map<String, dynamic>? map) =>
      BusinessProfileEntity(
        legalName: map?['legalName'] as String? ?? '',
        address: map?['address'] as String? ?? '',
        gstin: map?['gstin'] as String? ?? '',
      );

  static Map<String, dynamic> _toMap(BusinessProfileEntity p) => {
    'legalName': p.legalName,
    'address': p.address,
    'gstin': p.gstin,
  };

  Stream<BusinessProfileEntity> watchProfile() {
    if (_useMock) {
      return () async* {
        final raw = _settingsBox.get(HiveKeys.simulatedBusinessProfile);
        yield _fromMap(
          raw == null ? null : Map<String, dynamic>.from(raw as Map),
        );
        yield* _controller.stream;
      }();
    }
    return _doc.snapshots().map((snap) => _fromMap(snap.data()));
  }

  Future<void> saveProfile(BusinessProfileEntity profile) async {
    if (_useMock) {
      await _settingsBox.put(
        HiveKeys.simulatedBusinessProfile,
        _toMap(profile),
      );
      _controller.add(profile);
      return;
    }
    await _doc.set(_toMap(profile));
  }
}
