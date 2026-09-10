import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/domain/repositories/wishlist_repository.dart';
import 'package:traders_retailer/features/wishlist/controllers/wishlist_controller.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

void main() {
  late MockWishlistRepository repository;
  late StreamController<Set<String>> wishlistStream;
  late WishlistController controller;

  setUp(() {
    repository = MockWishlistRepository();
    wishlistStream = StreamController<Set<String>>.broadcast();
    when(() => repository.watchWishlist()).thenAnswer((_) => wishlistStream.stream);
    when(() => repository.toggle(any())).thenAnswer((_) async {});
    controller = WishlistController(repository);
  });

  tearDown(() => wishlistStream.close());

  test('starts empty before the repository stream emits', () {
    expect(controller.state, isEmpty);
  });

  test('mirrors whatever the repository stream emits', () async {
    wishlistStream.add({'p1', 'p2'});
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, {'p1', 'p2'});
  });

  test('toggle delegates to the repository', () async {
    await controller.toggle('p1');
    verify(() => repository.toggle('p1')).called(1);
  });
}
