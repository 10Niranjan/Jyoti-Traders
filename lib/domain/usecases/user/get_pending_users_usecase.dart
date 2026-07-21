import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetPendingUsersUseCase {
  final UserRepository _repository;

  GetPendingUsersUseCase(this._repository);

  Stream<List<UserEntity>> call() {
    return _repository.watchPendingUsers();
  }
}
