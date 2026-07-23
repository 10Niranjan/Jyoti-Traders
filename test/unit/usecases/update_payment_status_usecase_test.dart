import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/repositories/order_repository.dart';
import 'package:traders_retailer/domain/usecases/order/update_payment_status_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late UpdatePaymentStatusUseCase useCase;

  setUpAll(() {
    registerFallbackValue(PaymentStatus.pending);
  });

  setUp(() {
    repository = MockOrderRepository();
    useCase = UpdatePaymentStatusUseCase(repository);
    when(() => repository.updatePaymentStatus(any(), any())).thenAnswer((_) async {});
  });

  test('confirms payment for the correct order', () async {
    await useCase('order_1', PaymentStatus.paid);

    verify(() => repository.updatePaymentStatus('order_1', PaymentStatus.paid)).called(1);
  });
}
