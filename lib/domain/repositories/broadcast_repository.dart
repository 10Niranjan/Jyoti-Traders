import '../entities/broadcast_entity.dart';

/// Local-only, like every other repository in this project's simulation
/// layer — but deliberately *not* per-uid, unlike cart/wishlist: a
/// broadcast is meant to be visible to every account, which on a single
/// device with no live Firestore project is exactly what a shared (not
/// per-uid-keyed) Hive entry gives for free.
abstract class BroadcastRepository {
  Stream<List<BroadcastEntity>> watchBroadcasts();

  Future<void> send({required String title, required String body});
}
