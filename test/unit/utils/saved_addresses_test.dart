import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/saved_addresses.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';

void main() {
  const shop = AddressEntity(street: '12 MG Road', city: 'Pune', pincode: '411001');

  test('appends a new saved address with a fresh id when nothing matches', () {
    final result = mergeSavedAddress(const [], shop, 'Shop');

    expect(result, hasLength(1));
    expect(result.single.label, 'Shop');
    expect(result.single.id, isNotEmpty);
  });

  test('re-saving the same street/city/pincode updates the label in place, not a duplicate', () {
    final existing = [shop.copyWith(id: 'addr-1', label: 'Old Label')];
    final result = mergeSavedAddress(existing, shop, 'New Label');

    expect(result, hasLength(1));
    expect(result.single.id, 'addr-1');
    expect(result.single.label, 'New Label');
  });

  test('match is case/whitespace-insensitive on street, city and pincode', () {
    final existing = [shop.copyWith(id: 'addr-1', label: 'Shop')];
    const typedDifferently = AddressEntity(
      street: '  12 mg road  ',
      city: 'PUNE',
      pincode: '411001',
    );
    final result = mergeSavedAddress(existing, typedDifferently, 'Shop 2');

    expect(result, hasLength(1));
    expect(result.single.id, 'addr-1');
  });

  test('a genuinely different address is appended alongside the existing one', () {
    final existing = [shop.copyWith(id: 'addr-1', label: 'Shop')];
    const warehouse = AddressEntity(street: '9 Industrial Estate', city: 'Pune', pincode: '411019');
    final result = mergeSavedAddress(existing, warehouse, 'Warehouse');

    expect(result, hasLength(2));
    expect(result.first.id, 'addr-1');
    expect(result.last.label, 'Warehouse');
  });
}
