import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/core/constants/hive_keys.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/broadcast_repository_impl.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/data/datasources/local/broadcast_local_datasource.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/bank_details_entity.dart';
import 'package:traders_retailer/domain/entities/business_hours_entity.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/entities/notification_preferences_entity.dart';
import 'package:traders_retailer/domain/repositories/broadcast_repository.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/features/notifications/controllers/broadcast_ingestion_controller.dart';

/// Minimal fake, mirroring the one in stock_alert_controller_test.dart.
class FakeAuthRepository implements AuthRepository {
  final UserModel user;
  FakeAuthRepository(this.user);

  @override
  Stream<UserModel?> get authStateChanges => Stream.value(user);

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  }) async => user;

  @override
  Future<UserModel?> signIn({required String email, required String password}) async => user;

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel?> refreshUserStatus(String uid) async => user;

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
  }) async => user;

  @override
  Future<void> updateFcmToken({required String uid, required String fcmToken}) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> added = [];

  @override
  Stream<List<NotificationEntity>> watchNotifications() => Stream.value(added);

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    added.add(notification);
  }

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
}

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

/// Same reasoning as stock_alert_controller_test.dart's helper: a change
/// needs several event-loop turns to propagate through auth stream ->
/// broadcastsProvider -> ref.listen.
Future<void> _settle([int turns = 10]) async {
  for (var i = 0; i < turns; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late Directory tempDir;
  late Box notificationsBox;
  late BroadcastRepository broadcastRepo;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('broadcast_ingestion_test_');
    Hive.init(tempDir.path);
    notificationsBox = await Hive.openBox(HiveBoxes.notificationsCache);
    broadcastRepo = BroadcastRepositoryImpl(BroadcastLocalDatasource(box: notificationsBox));
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  ProviderContainer container(FakeNotificationRepository notificationRepo) {
    final c = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
        broadcastRepositoryProvider.overrideWithValue(broadcastRepo),
        notificationRepositoryProvider.overrideWithValue(notificationRepo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('copies a broadcast sent before the retailer ever opens the app into their notification history', () async {
    await broadcastRepo.send(title: 'New stock arrived', body: 'Fresh Basmati Rice is back in stock.');
    final notificationRepo = FakeNotificationRepository();
    final c = container(notificationRepo);

    c.read(broadcastIngestionProvider);
    await _settle();

    expect(notificationRepo.added, hasLength(1));
    expect(notificationRepo.added.single.title, 'New stock arrived');
  });

  test('a broadcast sent after ingestion starts is still copied in', () async {
    final notificationRepo = FakeNotificationRepository();
    final c = container(notificationRepo);
    c.read(broadcastIngestionProvider);
    await _settle();
    expect(notificationRepo.added, isEmpty);

    await broadcastRepo.send(title: 'Price drop on rice', body: '5% off this week.');
    await _settle();

    expect(notificationRepo.added, hasLength(1));
  });

  test('the same broadcast is never copied twice, even across a fresh session (persisted dedupe)', () async {
    await broadcastRepo.send(title: 'New stock arrived', body: 'Fresh Basmati Rice is back in stock.');

    final firstSession = FakeNotificationRepository();
    final c1 = container(firstSession);
    c1.read(broadcastIngestionProvider);
    await _settle();
    expect(firstSession.added, hasLength(1));

    // A fresh app session (new ProviderContainer, new in-memory notification
    // repo) re-reads the same persisted "seen" set from Hive.
    final secondSession = FakeNotificationRepository();
    final c2 = container(secondSession);
    c2.read(broadcastIngestionProvider);
    await _settle();

    expect(secondSession.added, isEmpty);
  });
}
