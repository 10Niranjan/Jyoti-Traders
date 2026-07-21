import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../models/product_model.dart';

/// Firestore CRUD for products, with a Hive-simulation fallback while
/// Firebase is still on placeholder credentials.
///
/// Search is a client-side substring filter in both modes — the catalog is
/// small (dozens to a couple hundred SKUs per PRD §5), so a hosted search
/// index (Algolia etc.) would be over-engineering at this scale.
class ProductRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _catalogBox;
  bool _useMock = false;
  final _controller = StreamController<List<ProductModel>>.broadcast();

  ProductRemoteDatasource({FirebaseFirestore? firestore, required Box catalogBox})
      : _catalogBox = catalogBox {
    _init(firestore);
  }

  void _init(FirebaseFirestore? firestore) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      debugPrint('ProductRemoteDatasource: Firestore unavailable, using simulation mode: $e');
    }
  }

  CollectionReference<ProductModel> get _collection => _firestore!
      .collection(FirestorePaths.products)
      .withConverter<ProductModel>(
        fromFirestore: (snap, _) => ProductModel.fromFirestore(snap),
        toFirestore: (model, _) => model.toFirestore(),
      );

  Stream<List<ProductModel>> watchProducts({String? categoryId}) {
    if (_useMock) {
      return () async* {
        yield _filterForBrowsing(_readAllSimulated(), categoryId);
        yield* _controller.stream.map((list) => _filterForBrowsing(list, categoryId));
      }();
    }

    Query<ProductModel> query = _collection.where('isActive', isEqualTo: true);
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    return query.limit(200).snapshots().map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return [];

    final List<ProductModel> browsableProducts;
    if (_useMock) {
      browsableProducts = _filterForBrowsing(_readAllSimulated(), null);
    } else {
      final snap = await _collection.where('isActive', isEqualTo: true).limit(200).get();
      browsableProducts = snap.docs.map((d) => d.data()).toList();
    }
    return browsableProducts.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
  }

  Future<ProductModel?> getProductById(String productId) async {
    if (_useMock) {
      final list = _readAllSimulated();
      final idx = list.indexWhere((p) => p.id == productId);
      return idx == -1 ? null : list[idx];
    }
    final doc = await _collection.doc(productId).get();
    return doc.data();
  }

  Future<void> createProduct(ProductModel product) async {
    if (_useMock) {
      final list = _readAllSimulated()..add(product);
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(product.id).set(product);
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_useMock) {
      final list = _readAllSimulated();
      final idx = list.indexWhere((p) => p.id == product.id);
      if (idx != -1) list[idx] = product;
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(product.id).set(product, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String productId) async {
    if (_useMock) {
      final list = _readAllSimulated()..removeWhere((p) => p.id == productId);
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(productId).delete();
  }

  /// Applies the same "browsable" rules real Firestore queries enforce
  /// (`isActive == true`, optional `categoryId` filter) to the simulated list.
  List<ProductModel> _filterForBrowsing(List<ProductModel> list, String? categoryId) {
    return list
        .where((p) => p.isActive)
        .where((p) => categoryId == null || p.categoryId == categoryId)
        .toList();
  }

  /// Unfiltered — includes inactive products, since this is also the
  /// read-before-mutate base for create/update/delete. Filtering happens at
  /// the browsing call sites above, not here, or a deactivated product would
  /// be silently dropped from storage on the next write.
  List<ProductModel> _readAllSimulated() {
    final List<dynamic> raw = _catalogBox.get(HiveKeys.simulatedProducts, defaultValue: []);
    return raw
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveSimulated(List<ProductModel> list) async {
    await _catalogBox.put(
      HiveKeys.simulatedProducts,
      list.map((p) => p.toJson()).toList(),
    );
    _controller.add(list);
  }
}
