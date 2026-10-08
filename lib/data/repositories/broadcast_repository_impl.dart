import '../../domain/entities/broadcast_entity.dart';
import '../../domain/repositories/broadcast_repository.dart';
import '../datasources/local/broadcast_local_datasource.dart';

class BroadcastRepositoryImpl implements BroadcastRepository {
  final BroadcastLocalDatasource _local;

  BroadcastRepositoryImpl(this._local);

  @override
  Stream<List<BroadcastEntity>> watchBroadcasts() => _local.watchBroadcasts();

  @override
  Future<void> send({required String title, required String body}) => _local.send(title: title, body: body);
}
