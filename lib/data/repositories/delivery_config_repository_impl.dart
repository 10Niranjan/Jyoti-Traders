import '../../domain/entities/delivery_config_entity.dart';
import '../../domain/repositories/delivery_config_repository.dart';
import '../datasources/remote/delivery_config_remote_datasource.dart';
import '../models/delivery_config_model.dart';

class DeliveryConfigRepositoryImpl implements DeliveryConfigRepository {
  final DeliveryConfigRemoteDatasource _remote;

  DeliveryConfigRepositoryImpl(this._remote);

  @override
  Stream<DeliveryConfigEntity> watchConfig() {
    return _remote.watchConfig().map((m) => m.toEntity());
  }

  @override
  Future<void> updateConfig(DeliveryConfigEntity config) {
    return _remote.updateConfig(DeliveryConfigModel.fromEntity(config));
  }
}
