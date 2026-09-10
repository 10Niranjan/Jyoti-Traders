import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/broadcast_entity.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';

final broadcastsProvider = StreamProvider.autoDispose<List<BroadcastEntity>>((ref) {
  return ref.watch(broadcastRepositoryProvider).watchBroadcasts();
});

/// Copies each admin broadcast the signed-in retailer hasn't seen yet into
/// their own notification history — reusing 100% of the existing
/// NotificationsScreen/bell-badge/mark-as-read machinery instead of
/// building a second, parallel "broadcasts" UI. Watched once from the app
/// root (mirrors `fcmInitializerProvider`/`stockAlertInitializerProvider`).
///
/// Unlike the stock alert's in-memory dedupe, "seen" here is persisted to
/// Hive (per uid) — a broadcast is a one-time historical event, not a
/// still-true condition, so re-copying it on every app restart would
/// duplicate it in the retailer's history forever instead of just once.
///
/// Listens to auth and broadcasts *unconditionally* rather than gating the
/// whole subscription behind an early `if (authState is! AuthenticatedCustomer)
/// return`: that early-return shape (fine inside a `StreamProvider`, which
/// every watcher re-reads reactively) silently never re-subscribes here,
/// since nothing keeps re-reading this specific provider once its first,
/// too-early build bails out — auth starts as `AuthLoading` and only
/// resolves a microtask later. Reacting to either source changing and
/// re-checking both fresh each time avoids depending on which one settles
/// first.
final broadcastIngestionProvider = Provider<void>((ref) {
  Future<void> ingest() async {
    final authState = ref.read(authControllerProvider);
    if (authState is! AuthenticatedCustomer) return;
    final uid = authState.user.uid;

    final broadcasts = ref.read(broadcastsProvider).valueOrNull;
    if (broadcasts == null || broadcasts.isEmpty) return;

    final box = Hive.box(HiveBoxes.notificationsCache);
    final seenKey = '${HiveKeys.seenBroadcastIds}_$uid';
    final seen = (box.get(seenKey, defaultValue: const <dynamic>[]) as List).cast<String>().toSet();

    final unseen = broadcasts.where((b) => !seen.contains(b.id)).toList();
    if (unseen.isEmpty) return;

    final notificationRepo = ref.read(notificationRepositoryProvider);
    for (final broadcast in unseen) {
      await notificationRepo.addNotification(
        NotificationEntity(
          id: const Uuid().v4(),
          title: broadcast.title,
          body: broadcast.body,
          receivedAt: broadcast.sentAt,
          isRead: false,
        ),
      );
      seen.add(broadcast.id);
    }
    await box.put(seenKey, seen.toList());
  }

  ref.listen(authControllerProvider, (previous, next) => ingest(), fireImmediately: true);
  ref.listen(broadcastsProvider, (previous, next) => ingest(), fireImmediately: true);
});
