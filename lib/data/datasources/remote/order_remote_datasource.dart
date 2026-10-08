import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/order_model.dart';

/// Firestore CRUD for orders, with a Hive-simulation fallback while
/// Firebase is still on placeholder credentials.
class OrderRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _ordersBox;
  bool _useMock = false;
  final _controller = StreamController<List<OrderModel>>.broadcast();

  OrderRemoteDatasource({FirebaseFirestore? firestore, required Box ordersBox})
      : _ordersBox = ordersBox {
    _init(firestore);
  }

  void _init(FirebaseFirestore? firestore) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning('OrderRemoteDatasource: Firestore unavailable, using simulation mode', e);
    }
  }

  CollectionReference<OrderModel> get _collection => _firestore!
      .collection(FirestorePaths.orders)
      .withConverter<OrderModel>(
        fromFirestore: (snap, _) => OrderModel.fromFirestore(snap),
        toFirestore: (model, _) => model.toFirestore(),
      );

  Future<void> placeOrder(OrderModel order) async {
    if (_useMock) {
      final list = _readSimulated()..add(order);
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(order.id).set(order);
  }

  Stream<List<OrderModel>> watchOrderHistory(String userId) {
    if (_useMock) {
      return () async* {
        yield _sortNewestFirst(_readSimulated().where((o) => o.userId == userId).toList());
        yield* _controller.stream.map(
          (list) => _sortNewestFirst(list.where((o) => o.userId == userId).toList()),
        );
      }();
    }
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<OrderModel>> watchAllOrders() {
    if (_useMock) {
      return () async* {
        yield _sortNewestFirst(_readSimulated());
        yield* _controller.stream.map(_sortNewestFirst);
      }();
    }
    return _collection
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (_useMock) {
      final list = _readSimulated();
      final idx = list.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final updated = OrderModel.fromJson({...list[idx].toJson(), 'orderStatus': status});
        list[idx] = updated;
      }
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(orderId).update({'orderStatus': status});
  }

  Future<void> updatePaymentStatus(String orderId, String status) async {
    if (_useMock) {
      final list = _readSimulated();
      final idx = list.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        list[idx] = OrderModel.fromJson({...list[idx].toJson(), 'paymentStatus': status});
      }
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(orderId).update({'paymentStatus': status});
  }

  Future<void> recordPaymentClaim(String orderId, {String? screenshotUrl}) async {
    const claimedStatus = 'payment_claimed';
    if (_useMock) {
      final list = _readSimulated();
      final idx = list.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final json = {...list[idx].toJson(), 'paymentStatus': claimedStatus};
        if (screenshotUrl != null) json['paymentScreenshotUrl'] = screenshotUrl;
        list[idx] = OrderModel.fromJson(json);
      }
      await _saveSimulated(list);
      return;
    }
    final update = <String, dynamic>{'paymentStatus': claimedStatus};
    if (screenshotUrl != null) update['paymentScreenshotUrl'] = screenshotUrl;
    await _collection.doc(orderId).update(update);
  }

  List<OrderModel> _sortNewestFirst(List<OrderModel> list) {
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<OrderModel> _readSimulated() {
    final List<dynamic> raw = _ordersBox.get(HiveKeys.simulatedOrders, defaultValue: []);
    return raw.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveSimulated(List<OrderModel> list) async {
    await _ordersBox.put(HiveKeys.simulatedOrders, list.map((o) => o.toJson()).toList());
    _controller.add(list);
  }
}
