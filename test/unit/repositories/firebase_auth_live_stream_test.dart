// Mocking FlutterFire's @sealed Firestore types is the usual test practice
// (no fake_cloud_firestore dependency here).
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/firebase_auth_repository.dart';

class _Auth extends Mock implements fb.FirebaseAuth {}

class _App extends Mock implements FirebaseApp {}

class _Firestore extends Mock implements FirebaseFirestore {}

class _Users extends Mock implements CollectionReference<Map<String, dynamic>> {}

class _DocRef extends Mock implements DocumentReference<Map<String, dynamic>> {}

class _Snap extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class _User extends Mock implements fb.User {}

_Snap _snap(String status) {
  final s = _Snap();
  when(() => s.data()).thenReturn({
    'uid': 'u1',
    'name': 'Ramesh',
    'email': 'u1@test.com',
    'phone': '9876543210',
    'role': 'customer',
    'status': status,
    'businessName': 'Ramesh Kirana',
  });
  return s;
}

/// Regression: in live Firebase mode the signed-in user was read once at
/// sign-in, so profile saves and an admin's approval never reached the app
/// until a restart. The auth stream now follows the profile document.
void main() {
  late Directory tempDir;
  late Box box;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('jyoti_auth_live_');
    Hive.init(tempDir.path);
    box = await Hive.openBox('user_cache_live_test');
  });

  tearDown(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('auth state follows the profile document, and stops on sign-out', () async {
    final auth = _Auth();
    final app = _App();
    final firestore = _Firestore();
    final users = _Users();
    final docRef = _DocRef();
    final fbUser = _User();
    final authEvents = StreamController<fb.User?>();
    final docEvents = StreamController<DocumentSnapshot<Map<String, dynamic>>>();

    when(() => auth.app).thenReturn(app);
    when(() => app.options).thenReturn(
      const FirebaseOptions(
        apiKey: 'live-key',
        appId: '1:1:android:1',
        messagingSenderId: '1',
        projectId: 'jyoti-traders-app',
      ),
    );
    when(() => auth.authStateChanges()).thenAnswer((_) => authEvents.stream);
    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(docRef);
    when(() => docRef.snapshots()).thenAnswer((_) => docEvents.stream);
    when(() => fbUser.uid).thenReturn('u1');

    final repo = FirebaseAuthRepository(
      firebaseAuth: auth,
      firestore: firestore,
      userCacheBox: box,
    );
    final emitted = <UserModel?>[];
    final sub = repo.authStateChanges.listen(emitted.add);

    authEvents.add(fbUser);
    await pumpEventQueue();
    docEvents.add(_snap('pending'));
    await pumpEventQueue();
    expect(emitted.last!.isApproved, isFalse);

    // The admin approves: the open stream must carry it, no re-login.
    docEvents.add(_snap('approved'));
    await pumpEventQueue();
    expect(emitted.last!.isApproved, isTrue);

    authEvents.add(null);
    await pumpEventQueue();
    expect(emitted.last, isNull);
    expect(docEvents.hasListener, isFalse);

    await sub.cancel();
  });
}
