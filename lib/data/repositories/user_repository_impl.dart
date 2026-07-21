import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _remote;

  UserRepositoryImpl(this._remote);

  @override
  Stream<List<UserEntity>> watchPendingUsers() {
    return _remote.watchPendingUsers().map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<UserEntity>> getApprovedUsers() async {
    final list = await _remote.getApprovedUsers();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> approveUser(String uid) {
    return _remote.approveUser(uid);
  }

  @override
  Future<void> rejectUser(String uid) {
    return _remote.rejectUser(uid);
  }
}
