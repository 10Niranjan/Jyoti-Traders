import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/delivery_config_model.dart';

/// Firestore CRUD for the single `config/delivery` document, with a
/// Hive-simulation fallback — same dual-mode pattern every other datasource
/// in this app uses, just over one document instead of a collection.
class DeliveryConfigRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _settingsBox;
  bool _useMock = false;
  final _controller = StreamController<DeliveryConfigModel>.broadcast();

  DeliveryConfigRemoteDatasource({FirebaseFirestore? firestore, required Box settingsBox})
      : _settingsBox = settingsBox {
    _init(firestore);
  }

  void _init(FirebaseFirestore? firestore) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning('DeliveryConfigRemoteDatasource: Firestore unavailable, using simulation mode', e);
    }
  }

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore!.collection(FirestorePaths.config).doc(FirestorePaths.deliveryConfigDoc);

  Stream<DeliveryConfigModel> watchConfig() {
    if (_useMock) {
      return () async* {
        yield _readSimulated();
        yield* _controller.stream;
      }();
    }
    return _doc.snapshots().map((snap) => DeliveryConfigModel.fromFirestore(snap));
  }

  Future<void> updateConfig(DeliveryConfigModel config) async {
    if (_useMock) {
      await _saveSimulated(config);
      return;
    }
    await _doc.set(config.toFirestore());
  }

  DeliveryConfigModel _readSimulated() {
    final raw = _settingsBox.get(HiveKeys.simulatedDeliveryConfig);
    if (raw == null) return DeliveryConfigModel.defaultConfig;
    return DeliveryConfigModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> _saveSimulated(DeliveryConfigModel config) async {
    await _settingsBox.put(HiveKeys.simulatedDeliveryConfig, config.toJson());
    _controller.add(config);
  }
}
