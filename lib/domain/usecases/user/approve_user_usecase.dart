import '../../repositories/user_repository.dart';

class ApproveUserUseCase {
  final UserRepository _repository;

  ApproveUserUseCase(this._repository);

  Future<void> call(String uid) {
    return _repository.approveUser(uid);
  }
}
