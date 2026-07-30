import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/cart_entity.dart';
import 'package:traders_retailer/domain/entities/cart_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';

/// The client's rate card, and the one the admin form prefills.
const slabs = WeightRateSlabs(
  below240g: 44,
  upto999g: 40,
  upto2400g: 39,
  above2400g: 38,
);

void main() {
  group('WeightRateSlabs band boundaries', () {
    test('under 240 g takes the highest rate', () {
      expect(slabs.ratePerKgFor(1), 44);
      expect(slabs.ratePerKgFor(100), 44);
      expect(slabs.ratePerKgFor(239), 44);
    });

    test('240 g is the first gram of the second band', () {
      expect(slabs.ratePerKgFor(240), 40);
      expect(slabs.ratePerKgFor(500), 40);
      expect(slabs.ratePerKgFor(999), 40);
    });

    test('the third band starts just above 999 g and includes 2.4 kg', () {
      expect(slabs.ratePerKgFor(1000), 39);
      expect(slabs.ratePerKgFor(2400), 39);
    });

    test('above 2.4 kg takes the bulk rate, however large', () {
      expect(slabs.ratePerKgFor(2401), 38);
      expect(slabs.ratePerKgFor(50000), 38);
    });
  });

  group('pricing', () {
    test('bills the whole weight at one rate, not marginally', () {
      // 3 kg at the bulk rate — NOT 240 g at ₹44 plus the remainder cheaper.
      expect(slabs.priceFor(3000).amount, 114); // 3 * 38
    });

    test('part-kilos keep their paise', () {
      expect(slabs.priceFor(100).amount, 4.40); // 0.1 * 44
      expect(slabs.priceFor(500).amount, 20); // 0.5 * 40
    });

    test('crossing a boundary can make more weight cost less', () {
      // The discount ladder's whole point: 240 g is cheaper than 239 g.
      expect(slabs.priceFor(239).amount, greaterThan(slabs.priceFor(240).amount));
    });

    test('rounds to whole paise so cart subtotals stay clean', () {
      final total = slabs.priceFor(333).amount;
      expect((total * 100) % 1, 0);
    });
  });

  group('ProductEntity pricing', () {
    ProductEntity product({required ProductUnit unit, WeightRateSlabs? rates}) =>
        ProductEntity(
          id: 'p1',
          name: 'Sugar',
          categoryId: 'c1',
          imageUrl: '',
          price: Money(50),
          unit: unit,
          stock: 10,
          isActive: true,
          rateSlabs: rates,
        );

    test('a kg product with rates prices off the ladder, in grams', () {
      final p = product(unit: ProductUnit.kg, rates: slabs);
      expect(p.isWeighed, isTrue);
      expect(p.priceForQty(500).amount, 20);
      expect(p.maxQty, 10000); // 10 kg of stock, counted in grams
    });

    test('a per-piece product is untouched by slab pricing', () {
      final p = product(unit: ProductUnit.piece, rates: null);
      expect(p.isWeighed, isFalse);
      expect(p.priceForQty(3).amount, 150); // 3 × ₹50, flat
      expect(p.maxQty, 10);
      expect(p.minQty, 1);
    });

    test('a kg product saved before slab pricing keeps flat per-kilo pricing', () {
      final p = product(unit: ProductUnit.kg, rates: null);
      expect(p.isWeighed, isFalse);
      expect(p.priceForQty(3).amount, 150); // 3 kg × ₹50, as it always was
    });
  });

  group('CartItemEntity', () {
    CartItemEntity item({required ProductUnit unit, WeightRateSlabs? rates, required int qty}) =>
        CartItemEntity(
          productId: 'p1',
          name: 'Sugar',
          imageUrl: '',
          unitPrice: Money(50),
          unit: unit,
          qty: qty,
          rateSlabs: rates,
        );

    test('re-prices onto a cheaper band as the quantity grows', () {
      final small = item(unit: ProductUnit.kg, rates: slabs, qty: 200);
      expect(small.ratePerKg, 44);

      final bulk = small.copyWith(qty: 5000);
      expect(bulk.ratePerKg, 38);
      expect(bulk.totalPrice.amount, 190); // 5 × 38
    });

    test('copyWith carries the rate card over', () {
      expect(item(unit: ProductUnit.kg, rates: slabs, qty: 300).copyWith(qty: 400).rateSlabs, slabs);
    });

    test('a non-weighed line still multiplies flat', () {
      expect(item(unit: ProductUnit.piece, qty: 4).totalPrice.amount, 200);
    });
  });

  test('a weighed line counts as one item, not its weight in grams', () {
    final cart = CartEntity(items: [
      CartItemEntity(
        productId: 'p1',
        name: 'Sugar',
        imageUrl: '',
        unitPrice: Money(44),
        unit: ProductUnit.kg,
        qty: 2500,
        rateSlabs: slabs,
      ),
      CartItemEntity(
        productId: 'p2',
        name: 'Soap',
        imageUrl: '',
        unitPrice: Money(30),
        unit: ProductUnit.piece,
        qty: 3,
      ),
    ]);
    expect(cart.itemCount, 4); // 1 weighed line + 3 pieces, not 2,503
    expect(cart.subtotal.amount, 185); // 2.5 × 38 = 95, plus 3 × 30 = 90
  });

  test('a partially-written rate map is rejected rather than priced at ₹0/kg', () {
    expect(WeightRateSlabs.fromJson({'below240g': 44}), isNull);
    expect(WeightRateSlabs.fromJson(null), isNull);
    expect(WeightRateSlabs.fromJson(slabs.toJson()), slabs);
  });
}
