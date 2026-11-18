import '../../domain/entities/broadcast_entity.dart';
import '../../domain/repositories/broadcast_repository.dart';
import '../datasources/remote/broadcast_remote_datasource.dart';

class BroadcastRepositoryImpl implements BroadcastRepository {
  final BroadcastRemoteDatasource _remote;

  BroadcastRepositoryImpl(this._remote);

  @override
  Stream<List<BroadcastEntity>> watchBroadcasts() => _remote.watchBroadcasts();

  @override
  Future<void> send({required String title, required String body}) => _remote.send(title: title, body: body);
}
