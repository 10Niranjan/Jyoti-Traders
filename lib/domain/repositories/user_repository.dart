import '../entities/user_entity.dart';

/// Admin-side user management — distinct from [AuthRepository], which owns
/// login/signup/session state. This repository is for approving, rejecting,
/// and listing retailers.
abstract class UserRepository {
  Stream<List<UserEntity>> watchPendingUsers();

  Stream<List<UserEntity>> watchApprovedUsers();

  Future<void> approveUser(String uid);

  Future<void> rejectUser(String uid);
}
