import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/domain/value_objects/weight_rate_slabs.dart';
import 'package:traders_retailer/features/cart/controllers/cart_nudge_controller.dart';

ProductEntity _p(
  String id,
  double price, {
  int stock = 10,
  ProductUnit unit = ProductUnit.box,
  WeightRateSlabs? slabs,
}) => ProductEntity(
  id: id,
  name: id,
  categoryId: 'c',
  imageUrl: '',
  price: Money(price),
  unit: unit,
  stock: stock,
  isActive: true,
  rateSlabs: slabs,
);

List<String> _ids(List<ProductEntity> l) => l.map((p) => p.id).toList();

void main() {
  test(
    'drops products already in the cart, out of stock, or too small to ever close the gap',
    () {
      final result = suggestGapClosers(
        products: [
          _p('ok', 600, stock: 5),
          _p('incart', 600),
          _p('soldout', 600, stock: 0),
          _p('tiny', 10, stock: 5), // 5 x ₹10 = ₹50, can never reach ₹500
        ],
        cartProductIds: {'incart'},
        frequentIds: const {},
        gap: 500,
      );
      expect(_ids(result), ['ok']);
    },
  );

  test(
    'regulars come first, then whichever first add lands closest to the gap',
    () {
      final result = suggestGapClosers(
        products: [
          _p('far', 900),
          _p('near', 520),
          _p('regular', 100, stock: 20),
        ],
        cartProductIds: const {},
        frequentIds: {'regular'},
        gap: 500,
      );
      expect(_ids(result), ['regular', 'near', 'far']);
    },
  );

  test(
    'a weighed product is priced at a round kilo, not per gram or per unit',
    () {
      final result = suggestGapClosers(
        products: [
          _p('box', 500),
          _p(
            'dal',
            44,
            unit: ProductUnit.kg,
            stock: 5,
            slabs: WeightRateSlabs.defaults,
          ),
        ],
        cartProductIds: const {},
        frequentIds: const {},
        gap: 30,
      );
      // 1 kg of dal is ₹39 — nine rupees off the gap; a ₹500 box is far away.
      expect(_ids(result), ['dal', 'box']);
    },
  );

  test('caps the list', () {
    final many = [for (var i = 0; i < 10; i++) _p('p$i', 600)];
    final result = suggestGapClosers(
      products: many,
      cartProductIds: const {},
      frequentIds: const {},
      gap: 500,
      limit: 3,
    );
    expect(result, hasLength(3));
  });
}
