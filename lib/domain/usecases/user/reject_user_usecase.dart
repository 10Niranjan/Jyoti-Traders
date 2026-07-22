import '../../repositories/user_repository.dart';

class RejectUserUseCase {
  final UserRepository _repository;

  RejectUserUseCase(this._repository);

  Future<void> call(String uid) {
    return _repository.rejectUser(uid);
  }
}
