import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/services/image_upload_service.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/repositories/product_repository.dart';
import 'package:traders_retailer/domain/usecases/product/create_product_usecase.dart';
import 'package:traders_retailer/domain/usecases/product/delete_product_usecase.dart';
import 'package:traders_retailer/domain/usecases/product/update_product_usecase.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';
import 'package:traders_retailer/features/admin/controllers/admin_product_controller.dart';

class FakeProductRepository implements ProductRepository {
  final List<ProductEntity> saved = [];
  final Set<String> failFor;

  FakeProductRepository({this.failFor = const {}});

  @override
  Future<void> updateProduct(ProductEntity product) async {
    if (failFor.contains(product.id)) {
      throw Exception('simulated failure for ${product.id}');
    }
    saved.add(product);
  }

  @override
  Stream<List<ProductEntity>> watchProducts({String? categoryId}) =>
      Stream.value(const []);

  @override
  Stream<List<ProductEntity>> watchAllProducts() => Stream.value(const []);

  @override
  Future<List<ProductEntity>> searchProducts(String query) async => [];

  @override
  Future<ProductEntity?> getProductById(String productId) async => null;

  @override
  Future<void> createProduct(ProductEntity product) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

ProductEntity _product(String id, {double price = 100, int stock = 10}) =>
    ProductEntity(
      id: id,
      name: id,
      categoryId: 'c1',
      imageUrl: '',
      price: Money(price),
      unit: ProductUnit.piece,
      stock: stock,
      isActive: true,
    );

void main() {
  late FakeProductRepository repository;

  AdminProductController buildController() {
    return AdminProductController(
      CreateProductUseCase(repository),
      UpdateProductUseCase(repository),
      DeleteProductUseCase(repository),
      ImageUploadService(),
    );
  }

  setUp(() {
    repository = FakeProductRepository();
  });

  test(
    'bulkUpdate applies the transform to every product and reports the count',
    () async {
      final controller = buildController();
      final products = [_product('p1'), _product('p2')];

      final count = await controller.bulkUpdate(
        products,
        (p) => p.copyWith(stock: 50),
      );

      expect(count, 2);
      expect(repository.saved.map((p) => p.stock), [50, 50]);
      expect(controller.state, const AsyncValue<void>.data(null));
    },
  );

  test('bulkUpdate skips a failing product but still saves the rest', () async {
    repository = FakeProductRepository(failFor: {'p2'});
    final controller = buildController();
    final products = [_product('p1'), _product('p2'), _product('p3')];

    final count = await controller.bulkUpdate(
      products,
      (p) => p.copyWith(stock: 20),
    );

    expect(count, 2);
    expect(repository.saved.map((p) => p.id), ['p1', 'p3']);
  });

  test('ProductEntity.copyWith updates price and stock independently', () {
    final product = _product('p1', price: 100, stock: 10);

    expect(product.copyWith(stock: 25).price.amount, 100);
    expect(product.copyWith(stock: 25).stock, 25);
    expect(product.copyWith(price: Money(150)).stock, 10);
    expect(product.copyWith(price: Money(150)).price.amount, 150);
  });
}
