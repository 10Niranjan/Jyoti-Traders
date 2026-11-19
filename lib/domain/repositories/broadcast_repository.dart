import '../entities/broadcast_entity.dart';

/// Every retailer sees every broadcast: a shared Firestore `broadcasts`
/// collection in live mode, a shared (not per-uid) Hive entry in simulation
/// mode. Each retailer's "already seen" set is what stays per-uid.
abstract class BroadcastRepository {
  Stream<List<BroadcastEntity>> watchBroadcasts();

  Future<void> send({required String title, required String body});
}
