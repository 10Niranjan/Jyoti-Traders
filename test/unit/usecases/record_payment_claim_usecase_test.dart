import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/usecases/order/record_payment_claim_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late RecordPaymentClaimUseCase useCase;

  setUp(() {
    repository = MockOrderRepository();
    useCase = RecordPaymentClaimUseCase(repository);
    when(() => repository.recordPaymentClaim(any(), screenshotUrl: any(named: 'screenshotUrl')))
        .thenAnswer((_) async {});
  });

  test('records a claim with no screenshot', () async {
    await useCase('order_1');

    verify(() => repository.recordPaymentClaim('order_1', screenshotUrl: null)).called(1);
  });

  test('records a claim with an uploaded screenshot URL', () async {
    await useCase('order_1', screenshotUrl: 'https://example.com/shot.jpg');

    verify(() => repository.recordPaymentClaim('order_1', screenshotUrl: 'https://example.com/shot.jpg')).called(1);
  });
}
