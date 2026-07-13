import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_repository.dart';
import 'firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final userCacheBox = Hive.box('user_cache');
  return FirebaseAuthRepository(userCacheBox: userCacheBox);
});
