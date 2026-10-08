import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/promo_banner_entity.dart';
import '../../models/promo_banner_model.dart';

/// Firestore access to the single `config/banners` document, with the same
/// Hive-simulation fallback as every other datasource (mirrors
/// `DeliveryConfigRemoteDatasource`). Reuses the existing `config/{doc}`
/// security rule — signed-in read, admin write.
class PromoBannerRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _settingsBox;
  bool _useMock = false;
  final _controller = StreamController<List<PromoBannerEntity>>.broadcast();

  PromoBannerRemoteDatasource({
    FirebaseFirestore? firestore,
    required Box settingsBox,
  }) : _settingsBox = settingsBox {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning(
        'PromoBannerRemoteDatasource: Firestore unavailable, using simulation mode',
        e,
      );
    }
  }

  DocumentReference<Map<String, dynamic>> get _doc => _firestore!
      .collection(FirestorePaths.config)
      .doc(FirestorePaths.bannersConfigDoc);

  Stream<List<PromoBannerEntity>> watchBanners() {
    if (_useMock) {
      return () async* {
        yield _readSimulated();
        yield* _controller.stream;
      }();
    }
    return _doc.snapshots().map(
      (snap) => PromoBannerModel.listFromJson(snap.data()),
    );
  }

  Future<void> saveBanners(List<PromoBannerEntity> banners) async {
    if (_useMock) {
      await _settingsBox.put(
        HiveKeys.simulatedPromoBanners,
        PromoBannerModel.listToJson(banners),
      );
      _controller.add(banners);
      return;
    }
    await _doc.set(PromoBannerModel.listToJson(banners));
  }

  List<PromoBannerEntity> _readSimulated() {
    final raw = _settingsBox.get(HiveKeys.simulatedPromoBanners);
    if (raw == null) return const [];
    return PromoBannerModel.listFromJson(Map<String, dynamic>.from(raw as Map));
  }
}
