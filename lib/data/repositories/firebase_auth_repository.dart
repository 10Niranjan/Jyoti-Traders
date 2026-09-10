import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_repository.dart';
import '../models/user_model.dart';
import '../../core/network/firebase_mode.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/business_hours_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';

class FirebaseAuthRepository implements AuthRepository {
  fb.FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;
  final Box _userCacheBox;

  final _mockStreamController = StreamController<UserModel?>.broadcast();
  bool _useMock = false;
  UserModel? _mockCurrentUser;

  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    required Box userCacheBox,
  }) : _userCacheBox = userCacheBox {
    _initFirebaseAndMock(firebaseAuth, firestore);
  }

  void _initFirebaseAndMock(
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  ) {
    try {
      _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;
      _firestore = firestore ?? FirebaseFirestore.instance;

      if (isFirebasePlaceholder(_firebaseAuth!.app)) {
        _useMock = true;
        _initMockUser();
      } else {
        _useMock = false;
      }
    } catch (e) {
      _useMock = true;
      _initMockUser();
      logWarning('AuthRepository: Firebase not available, using simulation mode', e);
    }
    logWarning('AuthRepository: Running in ${_useMock ? "SIMULATION" : "FIREBASE"} mode.');
  }

  void _initMockUser() {
    final cached = _userCacheBox.get('current_user');
    if (cached != null) {
      try {
        final Map<String, dynamic> map = Map<String, dynamic>.from(
          cached as Map,
        );
        _mockCurrentUser = UserModel.fromJson(map);
        _mockStreamController.add(_mockCurrentUser);
      } catch (e) {
        logWarning('Error loading cached user', e);
      }
    } else {
      _mockStreamController.add(null);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    if (_useMock) {
      return () async* {
        yield _mockCurrentUser;
        yield* _mockStreamController.stream;
      }();
    }

    return _firebaseAuth!.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        return null;
      }
      return await _getUserFromFirestore(fbUser.uid);
    });
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromJson(doc.data()!);
        // Sync to cache
        await _userCacheBox.put('current_user', user.toJson());
        return user;
      }
    } catch (e) {
      logWarning('Firestore read error', e);
    }

    // Check cache as fallback
    final cached = _userCacheBox.get('current_user');
    if (cached != null) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(cached as Map);
      final cachedUser = UserModel.fromJson(map);
      if (cachedUser.uid == uid) {
        return cachedUser;
      }
    }
    return null;
  }

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if user already exists in simulated db
      final List<dynamic> users = _userCacheBox.get(
        'simulated_users',
        defaultValue: [],
      );
      final exists = users.any((u) => (u as Map)['email'] == email);
      if (exists) {
        throw Exception('An account already exists with this email address.');
      }

      final uid = 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';

      // Admins are approved by default; normal users need manual approval
      final status = role == UserRole.admin
          ? UserStatus.approved
          : UserStatus.pending;

      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        status: status,
        businessName: businessName,
        createdAt: DateTime.now(),
      );

      // Save to simulation database list
      final userMapList = List<Map<String, dynamic>>.from(
        users.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      userMapList.add(newUser.toJson());
      await _userCacheBox.put('simulated_users', userMapList);

      // Set current session
      _mockCurrentUser = newUser;
      await _userCacheBox.put('current_user', newUser.toJson());
      _mockStreamController.add(newUser);

      return newUser;
    }

    // Firebase Auth implementation
    final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = userCredential.user;
    if (fbUser == null) {
      throw Exception('User creation failed.');
    }

    // Admin is approved by default
    final status = role == UserRole.admin
        ? UserStatus.approved
        : UserStatus.pending;
    final user = UserModel(
      uid: fbUser.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      status: status,
      businessName: businessName,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await _firestore!.collection('users').doc(fbUser.uid).set(user.toJson());
    await _userCacheBox.put('current_user', user.toJson());

    return user;
  }

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));

      // Special accounts for quick testing
      if (email == 'admin@jyoti.com' && password == 'admin123') {
        final admin = UserModel(
          uid: 'mock_admin_uid',
          name: 'Admin Owner',
          email: 'admin@jyoti.com',
          phone: '9860460325',
          role: UserRole.admin,
          status: UserStatus.approved,
          businessName: 'Jyoti Traders Wholesale',
          createdAt: DateTime.now(),
        );
        _mockCurrentUser = admin;
        await _userCacheBox.put('current_user', admin.toJson());
        _mockStreamController.add(admin);
        return admin;
      }

      if (email == 'retailer@jyoti.com' && password == 'retailer123') {
        final retailer = UserModel(
          uid: 'mock_retailer_uid',
          name: 'Retailer Ram',
          email: 'retailer@jyoti.com',
          phone: '9876543210',
          role: UserRole.customer,
          status: UserStatus.approved,
          businessName: 'Ram Kirana Store',
          createdAt: DateTime.now(),
        );
        _mockCurrentUser = retailer;
        await _userCacheBox.put('current_user', retailer.toJson());
        _mockStreamController.add(retailer);
        return retailer;
      }

      // Pending-approval demo account, for testing the "browse while
      // pending" flow without depending on a prior sign-up surviving a
      // reinstall (Hive-simulated accounts don't).
      if (email == 'nirmala.store@example.com' && password == 'Nirmala@123') {
        final nirmala = UserModel(
          uid: 'mock_nirmala_uid',
          name: 'Nirmala Devi',
          email: 'nirmala.store@example.com',
          phone: '9876543210',
          role: UserRole.customer,
          status: UserStatus.pending,
          businessName: 'Nirmala Provision Store',
          createdAt: DateTime.now(),
        );
        _mockCurrentUser = nirmala;
        await _userCacheBox.put('current_user', nirmala.toJson());
        _mockStreamController.add(nirmala);
        return nirmala;
      }

      // Check simulated users list
      final List<dynamic> users = _userCacheBox.get(
        'simulated_users',
        defaultValue: [],
      );
      final matchIndex = users.indexWhere((u) => (u as Map)['email'] == email);
      final matchingUserMap = matchIndex == -1 ? null : users[matchIndex];

      if (matchingUserMap == null) {
        throw Exception('No account found for this email address.');
      }

      final foundUser = UserModel.fromJson(
        Map<String, dynamic>.from(matchingUserMap as Map),
      );
      _mockCurrentUser = foundUser;
      await _userCacheBox.put('current_user', foundUser.toJson());
      _mockStreamController.add(foundUser);
      return foundUser;
    }

    // Firebase Auth implementation
    final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final fbUser = userCredential.user;
    if (fbUser == null) {
      throw Exception('Login failed.');
    }

    final user = await _getUserFromFirestore(fbUser.uid);
    if (user == null) {
      throw Exception('User data not found in database.');
    }

    return user;
  }

  @override
  Future<void> signOut() async {
    if (_useMock) {
      _mockCurrentUser = null;
      await _userCacheBox.delete('current_user');
      _mockStreamController.add(null);
      return;
    }

    await _firebaseAuth!.signOut();
    await _userCacheBox.delete('current_user');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_useMock) {
      return _mockCurrentUser;
    }

    final fbUser = _firebaseAuth!.currentUser;
    if (fbUser == null) return null;
    return await _getUserFromFirestore(fbUser.uid);
  }

  @override
  Future<UserModel?> refreshUserStatus(String uid) async {
    if (_useMock) {
      // Re-read simulated database list
      final List<dynamic> users = _userCacheBox.get(
        'simulated_users',
        defaultValue: [],
      );
      final matchIndex = users.indexWhere((u) => (u as Map)['uid'] == uid);
      final matchingUserMap = matchIndex == -1 ? null : users[matchIndex];

      if (matchingUserMap != null) {
        final updated = UserModel.fromJson(
          Map<String, dynamic>.from(matchingUserMap as Map),
        );
        if (_mockCurrentUser?.uid == uid) {
          _mockCurrentUser = updated;
          await _userCacheBox.put('current_user', updated.toJson());
          _mockStreamController.add(updated);
        }
        return updated;
      }
      return _mockCurrentUser;
    }

    // Firebase Auth implementation
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromJson(doc.data()!);
        await _userCacheBox.put('current_user', user.toJson());
        return user;
      }
    } catch (e) {
      logWarning('Error refreshing user status', e);
    }
    return null;
  }

  @override
  Future<UserModel?> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? businessName,
    String? photoUrl,
    AddressEntity? address,
    List<AddressEntity>? savedAddresses,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) async {
    if (_useMock) {
      final List<dynamic> users = _userCacheBox.get(
        'simulated_users',
        defaultValue: [],
      );
      final userMapList = List<Map<String, dynamic>>.from(
        users.map((e) => Map<String, dynamic>.from(e as Map)),
      );

      UserModel? updated;
      final index = userMapList.indexWhere((u) => u['uid'] == uid);
      if (index != -1) {
        final current = UserModel.fromJson(userMapList[index]);
        updated = current.copyWith(
          name: name,
          phone: phone,
          businessName: businessName,
          photoUrl: photoUrl,
          address: address,
          savedAddresses: savedAddresses,
          gstNumber: gstNumber,
          bankDetails: bankDetails,
          businessHours: businessHours,
          notificationPreferences: notificationPreferences,
        );
        userMapList[index] = updated.toJson();
        await _userCacheBox.put('simulated_users', userMapList);
      } else if (_mockCurrentUser?.uid == uid) {
        // The special-cased quick-login accounts (admin@jyoti.com,
        // retailer@jyoti.com, ...) are synthesized fresh on every signIn and
        // never land in simulated_users, so an index match never happens for
        // them — update the in-memory session directly instead, or their
        // profile edits (e.g. saving a checkout address) silently no-op.
        updated = _mockCurrentUser!.copyWith(
          name: name,
          phone: phone,
          businessName: businessName,
          photoUrl: photoUrl,
          address: address,
          savedAddresses: savedAddresses,
          gstNumber: gstNumber,
          bankDetails: bankDetails,
          businessHours: businessHours,
          notificationPreferences: notificationPreferences,
        );
      }

      if (updated != null) {
        _mockCurrentUser = updated;
        await _userCacheBox.put('current_user', updated.toJson());
        _mockStreamController.add(updated);
      }
      return updated;
    }

    final updateData = <String, dynamic>{};
    if (name != null) {
      updateData['name'] = name;
    }
    if (phone != null) {
      updateData['phone'] = phone;
    }
    if (businessName != null) {
      updateData['businessName'] = businessName;
    }
    if (photoUrl != null) {
      updateData['photoUrl'] = photoUrl;
    }
    if (address != null) {
      updateData['address'] = {
        'street': address.street,
        'city': address.city,
        'pincode': address.pincode,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'formattedAddress': address.formattedAddress,
        'id': address.id,
        'label': address.label,
      };
    }
    if (savedAddresses != null) {
      updateData['savedAddresses'] = savedAddresses
          .map((a) => {
                'street': a.street,
                'city': a.city,
                'pincode': a.pincode,
                'latitude': a.latitude,
                'longitude': a.longitude,
                'formattedAddress': a.formattedAddress,
                'id': a.id,
                'label': a.label,
              })
          .toList();
    }
    if (gstNumber != null) {
      updateData['gstNumber'] = gstNumber;
    }
    if (bankDetails != null) {
      updateData['bankDetails'] = {
        'accountHolderName': bankDetails.accountHolderName,
        'accountNumber': bankDetails.accountNumber,
        'ifscCode': bankDetails.ifscCode,
        'bankName': bankDetails.bankName,
        'upiId': bankDetails.upiId,
      };
    }
    if (businessHours != null) {
      updateData['businessHours'] = {
        'openTime': businessHours.openTime,
        'closeTime': businessHours.closeTime,
        'is24x7': businessHours.is24x7,
      };
    }
    if (notificationPreferences != null) {
      updateData['notificationPreferences'] = {
        'orderUpdates': notificationPreferences.orderUpdates,
        'promotions': notificationPreferences.promotions,
        'lowStockAlerts': notificationPreferences.lowStockAlerts,
      };
    }
    if (updateData.isEmpty) {
      return getCurrentUser();
    }

    await _firestore!.collection('users').doc(uid).update(updateData);
    return _getUserFromFirestore(uid);
  }

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String fcmToken,
  }) async {
    if (_useMock) {
      final List<dynamic> users = _userCacheBox.get(
        'simulated_users',
        defaultValue: [],
      );
      final userMapList = List<Map<String, dynamic>>.from(
        users.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      for (int i = 0; i < userMapList.length; i++) {
        if (userMapList[i]['uid'] == uid) {
          userMapList[i] = UserModel.fromJson(
            userMapList[i],
          ).copyWith(fcmToken: fcmToken).toJson();
        }
      }
      await _userCacheBox.put('simulated_users', userMapList);

      if (_mockCurrentUser?.uid == uid) {
        _mockCurrentUser = _mockCurrentUser!.copyWith(fcmToken: fcmToken);
        await _userCacheBox.put('current_user', _mockCurrentUser!.toJson());
        _mockStreamController.add(_mockCurrentUser);
      }
      return;
    }

    await _firestore!.collection('users').doc(uid).update({
      'fcmToken': fcmToken,
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }

    await _firebaseAuth!.sendPasswordResetEmail(email: email);
  }

  // Simulation-only helper to toggle approval status of a user (useful for admin testing screen)
  Future<void> simulateToggleApproval(String uid, bool approve) async {
    final status = approve ? UserStatus.approved : UserStatus.pending;

    if (!_useMock) {
      // Production database update
      await _firestore!.collection('users').doc(uid).update({
        'isApproved': approve,
        'status': status.value,
      });
      return;
    }

    final List<dynamic> users = _userCacheBox.get(
      'simulated_users',
      defaultValue: [],
    );
    final userMapList = List<Map<String, dynamic>>.from(
      users.map((e) => Map<String, dynamic>.from(e as Map)),
    );

    for (int i = 0; i < userMapList.length; i++) {
      if (userMapList[i]['uid'] == uid) {
        userMapList[i]['isApproved'] = approve;
        userMapList[i]['status'] = status.value;
      }
    }
    await _userCacheBox.put('simulated_users', userMapList);

    if (_mockCurrentUser?.uid == uid) {
      _mockCurrentUser = _mockCurrentUser!.copyWith(status: status);
      await _userCacheBox.put('current_user', _mockCurrentUser!.toJson());
      _mockStreamController.add(_mockCurrentUser);
    }
  }

  // Simulation-only helper to list all pending users
  Future<List<UserModel>> getPendingUsersSimulation() async {
    if (!_useMock) {
      final snap = await _firestore!
          .collection('users')
          .where('role', isEqualTo: 'customer')
          .where('isApproved', isEqualTo: false)
          .get();
      return snap.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
    }

    final List<dynamic> users = _userCacheBox.get(
      'simulated_users',
      defaultValue: [],
    );
    return users
        .map((u) => UserModel.fromJson(Map<String, dynamic>.from(u as Map)))
        .where((u) => u.role == UserRole.customer && !u.isApproved)
        .toList();
  }
}
