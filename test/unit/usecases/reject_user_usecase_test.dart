import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/repositories/user_repository.dart';
import 'package:traders_retailer/domain/usecases/user/reject_user_usecase.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository repository;
  late RejectUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = RejectUserUseCase(repository);
    when(() => repository.rejectUser(any())).thenAnswer((_) async {});
  });

  test('rejects the correct user by uid', () async {
    await useCase('retailer_uid_123');

    verify(() => repository.rejectUser('retailer_uid_123')).called(1);
  });

  test('does not call reject for a different uid', () async {
    await useCase('retailer_uid_123');

    verifyNever(() => repository.rejectUser('some_other_uid'));
  });
}
