import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/domain/usecases/user/approve_user_usecase.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late ApproveUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = ApproveUserUseCase(repository);
    when(() => repository.approveUser(any())).thenAnswer((_) async {});
  });

  test('approves the correct user by uid', () async {
    await useCase('retailer_uid_123');

    verify(() => repository.approveUser('retailer_uid_123')).called(1);
  });

  test('does not call approve for a different uid', () async {
    await useCase('retailer_uid_123');

    verifyNever(() => repository.approveUser('some_other_uid'));
  });
}
