import '../entities/delivery_config_entity.dart';

/// A single config document, not a collection — mirrors `CategoryRepository`
/// etc.'s Firestore/Hive-simulation dual-mode pattern, but for one document
/// rather than many.
abstract class DeliveryConfigRepository {
  Stream<DeliveryConfigEntity> watchConfig();

  Future<void> updateConfig(DeliveryConfigEntity config);
}
