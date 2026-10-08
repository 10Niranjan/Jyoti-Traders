import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/category_model.dart';

/// Firestore CRUD for categories, with a Hive-simulation fallback while
/// Firebase is still on placeholder credentials — mirrors the dual-mode
/// pattern in `FirebaseAuthRepository`.
class CategoryRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _catalogBox;
  bool _useMock = false;
  final _controller = StreamController<List<CategoryModel>>.broadcast();

  CategoryRemoteDatasource({FirebaseFirestore? firestore, required Box catalogBox})
      : _catalogBox = catalogBox {
    _init(firestore);
  }

  void _init(FirebaseFirestore? firestore) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      logWarning('CategoryRemoteDatasource: Firestore unavailable, using simulation mode', e);
    }
  }

  CollectionReference<CategoryModel> get _collection => _firestore!
      .collection(FirestorePaths.categories)
      .withConverter<CategoryModel>(
        fromFirestore: (snap, _) => CategoryModel.fromFirestore(snap),
        toFirestore: (model, _) => model.toFirestore(),
      );

  Stream<List<CategoryModel>> watchCategories() {
    if (_useMock) {
      return () async* {
        yield _readSimulated();
        yield* _controller.stream;
      }();
    }
    return _collection.orderBy('displayOrder').snapshots().map(
          (snap) => snap.docs.map((d) => d.data()).toList(),
        );
  }

  Future<void> createCategory(CategoryModel category) async {
    if (_useMock) {
      final list = _readSimulated()..add(category);
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(category.id).set(category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_useMock) {
      final list = _readSimulated();
      final idx = list.indexWhere((c) => c.id == category.id);
      if (idx != -1) list[idx] = category;
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(category.id).set(category, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_useMock) {
      final list = _readSimulated()..removeWhere((c) => c.id == categoryId);
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(categoryId).delete();
  }

  List<CategoryModel> _readSimulated() {
    final List<dynamic> raw = _catalogBox.get(HiveKeys.simulatedCategories, defaultValue: []);
    final list = raw
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<void> _saveSimulated(List<CategoryModel> list) async {
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    await _catalogBox.put(
      HiveKeys.simulatedCategories,
      list.map((c) => c.toJson()).toList(),
    );
    _controller.add(list);
  }
}
