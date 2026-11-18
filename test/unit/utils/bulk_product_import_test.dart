import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/bulk_product_import.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';

void main() {
  final categories = [
    const CategoryEntity(
      id: 'c1',
      name: 'Rice',
      iconUrl: '',
      displayOrder: 0,
      isActive: true,
    ),
    const CategoryEntity(
      id: 'c2',
      name: 'Oil',
      iconUrl: '',
      displayOrder: 1,
      isActive: true,
    ),
  ];

  test('parses valid rows into products, resolving category name to id', () {
    const csv =
        'name,category,price,unit,stock,description\n'
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

  test('accepts cells pasted from Excel / Google Sheets (tab-separated)', () {
    // A comma inside a cell must stay part of the cell, not split it.
    const tsv =
        'name\tcategory\tprice\tunit\tstock\tdescription\r\n'
        'Basmati Rice 25kg\tRice\t1800\tbox\t10\tLong grain, aged\r\n'
        'Loose Turmeric\tRice\t210\tkg\t12.5\t\r\n';
    final rows = parseBulkProductCsv(tsv, categories);

    expect(rows, hasLength(2));
    expect(rows.every((r) => r.isValid), isTrue);
    expect(rows[0].product!.description, 'Long grain, aged');
    expect(rows[1].product!.stock, 12.5); // kilos may be fractional
  });

  test('a fractional stock is only allowed for kg products', () {
    const csv =
        'name,category,price,unit,stock\n'
        'Rice Box,Rice,1800,box,2.5';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.isValid, isFalse);
    expect(rows.single.error, contains('whole number'));
  });

  test('flags a missing required column in the header', () {
    const csv = 'name,category,price,stock\nRice,Rice,100,10';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows, hasLength(1));
    expect(rows.single.isValid, isFalse);
    expect(rows.single.error, contains('unit'));
  });

  test('flags an unknown category by name', () {
    const csv =
        'name,category,price,unit,stock,description\nRice,Wheat,100,box,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Wheat'));
  });

  test('flags a non-positive price', () {
    const csv =
        'name,category,price,unit,stock,description\nRice,Rice,0,box,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Price'));
  });

  test('flags an invalid unit', () {
    const csv =
        'name,category,price,unit,stock,description\nRice,Rice,100,bag,10,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows.single.error, contains('Unit'));
  });

  test('skips blank lines without producing a row', () {
    const csv =
        'name,category,price,unit,stock,description\n'
        'Rice,Rice,100,box,10,\n'
        '\n'
        'Oil,Oil,150,litre,50,';
    final rows = parseBulkProductCsv(csv, categories);

    expect(rows, hasLength(2));
  });

  test('a kg product with all four rate-slab columns gets rateSlabs set', () {
    const csv =
        'name,category,price,unit,stock,description,below240g,upto999g,upto2400g,above2400g\n'
        'Sugar,Rice,44,kg,20,,44,40,39,38';
    final rows = parseBulkProductCsv(csv, categories);

    final slabs = rows.single.product!.rateSlabs;
    expect(slabs, isNotNull);
    expect(slabs!.below240g, 44);
    expect(slabs.above2400g, 38);
  });

  test(
    'a kg product always gets a rate card: blank rate columns use the price',
    () {
      // Without one it would be a "flat kg" product whose order lines read
      // as grams (3 kg shown and stocked as 3 g).
      const csv =
          'name,category,price,unit,stock,description,below240g\n'
          'Sugar,Rice,42,kg,20,,46\n'
          'Jaggery,Rice,60,kg,20,,';
      final rows = parseBulkProductCsv(csv, categories);

      final partial = rows[0].product!;
      expect(partial.isWeighed, isTrue);
      expect(partial.rateSlabs!.below240g, 46);
      expect(partial.rateSlabs!.above2400g, 42);

      final none = rows[1].product!.rateSlabs!;
      expect(
        [none.below240g, none.upto999g, none.upto2400g, none.above2400g],
        [60, 60, 60, 60],
      );
    },
  );

  test('empty input produces no rows', () {
    expect(parseBulkProductCsv('', categories), isEmpty);
  });
}
