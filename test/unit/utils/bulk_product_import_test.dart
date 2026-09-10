import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/bulk_product_import.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';

void main() {
  final categories = [
    const CategoryEntity(id: 'c1', name: 'Rice', iconUrl: '', displayOrder: 0, isActive: true),
    const CategoryEntity(id: 'c2', name: 'Oil', iconUrl: '', displayOrder: 1, isActive: true),
  ];

  test('parses valid rows into products, resolving category name to id', () {
    const csv = 'name,category,price,unit,stock,description\n'
        'Basmati Rice 25kg,Rice,1800,box,10,Premium long grain\n'
        'Sunflower Oil 1L,Oil,150,litre,50,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows, hasLength(2));
    expect(rows.every((r) => r.isValid), isTrue);
    expect(rows[0].product!.name, 'Basmati Rice 25kg');
    expect(rows[0].product!.categoryId, 'c1');
    expect(rows[0].product!.price.amount, 1800);
    expect(rows[0].product!.unit, ProductUnit.box);
    expect(rows[0].product!.stock, 10);
    expect(rows[0].product!.description, 'Premium long grain');
    expect(rows[1].product!.description, isNull);
  });

  test('flags a missing required column in the header', () {
    const csv = 'name,category,price,stock\nRice,Rice,100,10';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows, hasLength(1));
    expect(rows.single.isValid, isFalse);
    expect(rows.single.error, contains('unit'));
  });

  test('flags an unknown category by name', () {
    const csv = 'name,category,price,unit,stock,description\nRice,Wheat,100,box,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Wheat'));
  });

  test('flags a non-positive price', () {
    const csv = 'name,category,price,unit,stock,description\nRice,Rice,0,box,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Price'));
  });

  test('flags an invalid unit', () {
    const csv = 'name,category,price,unit,stock,description\nRice,Rice,100,bag,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Unit'));
  });

  test('skips blank lines without producing a row', () {
    const csv = 'name,category,price,unit,stock,description\n'
        'Rice,Rice,100,box,10,\n'
        '\n'
        'Oil,Oil,150,litre,50,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows, hasLength(2));
  });

  test('a kg product with all four rate-slab columns gets rateSlabs set', () {
    const csv = 'name,category,price,unit,stock,description,below240g,upto999g,upto2400g,above2400g\n'
        'Sugar,Rice,44,kg,20,,44,40,39,38';
    final rows = parseBulkProductCsv(csv, categories);

    final slabs = rows.single.product!.rateSlabs;
    expect(slabs, isNotNull);
    expect(slabs!.below240g, 44);
    expect(slabs.above2400g, 38);
  });

  test('a kg product with partial rate-slab columns falls back to flat pricing (no rateSlabs)', () {
    const csv = 'name,category,price,unit,stock,description,below240g\n'
        'Sugar,Rice,44,kg,20,,44';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.product!.rateSlabs, isNull);
  });

  test('empty input produces no rows', () {
    expect(parseBulkProductCsv('', categories), isEmpty);
  });
}
