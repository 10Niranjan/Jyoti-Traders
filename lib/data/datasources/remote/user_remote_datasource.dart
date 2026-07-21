import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../models/user_model.dart';

/// Admin-side user management (approve/reject/list). Reads and writes the
/// same `users` collection / `simulated_users` Hive list that
/// `FirebaseAuthRepository` already populates on sign-up — this is a second,
/// domain-compliant entry point onto that data, not a separate store.
class UserRemoteDatasource {
  FirebaseFirestore? _firestore;
  final Box _userCacheBox;
  bool _useMock = false;
  final _controller = StreamController<List<UserModel>>.broadcast();

  UserRemoteDatasource({FirebaseFirestore? firestore, required Box userCacheBox})
      : _userCacheBox = userCacheBox {
    _init(firestore);
  }

  void _init(FirebaseFirestore? firestore) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _useMock = isFirebasePlaceholder(_firestore!.app);
    } catch (e) {
      _useMock = true;
      debugPrint('UserRemoteDatasource: Firestore unavailable, using simulation mode: $e');
    }
  }

  CollectionReference<UserModel> get _collection => _firestore!
      .collection(FirestorePaths.users)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  Stream<List<UserModel>> watchPendingUsers() {
    if (_useMock) {
      return () async* {
        yield _readSimulated().where(_isPendingRetailer).toList();
        yield* _controller.stream.map((list) => list.where(_isPendingRetailer).toList());
      }();
    }
    return _collection
        .where('role', isEqualTo: 'customer')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<List<UserModel>> getApprovedUsers() async {
    if (_useMock) {
      return _readSimulated().where((u) => u.isApproved).toList();
    }
    final snap = await _collection
        .where('role', isEqualTo: 'customer')
        .where('status', isEqualTo: 'approved')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<void> approveUser(String uid) => _setStatus(uid, UserStatus.approved);

  Future<void> rejectUser(String uid) => _setStatus(uid, UserStatus.rejected);

  Future<void> _setStatus(String uid, UserStatus status) async {
    if (_useMock) {
      final list = _readSimulated();
      final idx = list.indexWhere((u) => u.uid == uid);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(status: status);
      }
      await _saveSimulated(list);
      return;
    }
    await _collection.doc(uid).update({
      'status': status.value,
      'isApproved': status == UserStatus.approved,
    });
  }

  bool _isPendingRetailer(UserModel u) => u.role == UserRole.customer && u.status == UserStatus.pending;

  List<UserModel> _readSimulated() {
    final List<dynamic> raw = _userCacheBox.get(HiveKeys.simulatedUsers, defaultValue: []);
    return raw.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveSimulated(List<UserModel> list) async {
    await _userCacheBox.put(HiveKeys.simulatedUsers, list.map((u) => u.toJson()).toList());
    _controller.add(list);
  }
}
