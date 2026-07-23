import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/delivery_config_entity.dart';
import 'package:traders_retailer/domain/usecases/delivery/calculate_delivery_charge_usecase.dart';

void main() {
  final useCase = CalculateDeliveryChargeUseCase();
  const config = DeliveryConfigEntity(warehouseLat: 19.0760, warehouseLng: 72.8777, perKmRate: 10.0);

  test('returns null when the address has no coordinates', () {
    const address = AddressEntity(street: 'St', city: 'City', pincode: '123456');

    expect(useCase(config: config, address: address), isNull);
  });

  test('returns distance-times-rate when the address has coordinates', () {
    const address = AddressEntity(
      street: 'St',
      city: 'City',
      pincode: '123456',
      latitude: 18.5204,
      longitude: 73.8567,
    );

    final charge = useCase(config: config, address: address);

    expect(charge, isNotNull);
    // ~120km Mumbai-Pune straight-line distance * ₹10/km.
    expect(charge!.amount, closeTo(1200, 100));
  });

  test('zero distance (retailer at the warehouse) yields a zero charge', () {
    const address = AddressEntity(
      street: 'St',
      city: 'City',
      pincode: '123456',
      latitude: 19.0760,
      longitude: 72.8777,
    );

    expect(useCase(config: config, address: address)!.amount, 0);
  });
}
