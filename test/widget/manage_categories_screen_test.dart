import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/features/admin/screens/manage_categories_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories;
  final List<String> deletedIds = [];
  final List<CategoryEntity> updated = [];

  FakeCategoryRepository(this.categories);

  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(categories);

  @override
  Future<void> createCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async =>
      updated.add(category);

  @override
  Future<void> deleteCategory(String categoryId) async =>
      deletedIds.add(categoryId);
}

CategoryEntity _category({
  required String id,
  required String name,
  int displayOrder = 0,
  bool isActive = true,
}) => CategoryEntity(
  id: id,
  name: name,
  iconUrl: '',
  displayOrder: displayOrder,
  isActive: isActive,
);

Widget _wrap(FakeCategoryRepository repo) => ProviderScope(
  overrides: [categoryRepositoryProvider.overrideWithValue(repo)],
  child: const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ManageCategoriesScreen(),
  ),
);

void main() {
  testWidgets('shows an empty state when there are no categories', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeCategoryRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No categories yet'), findsOneWidget);
  });

  testWidgets('lists categories in display order', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FakeCategoryRepository([
          _category(id: 'c1', name: 'Atta, Rice & Grains', displayOrder: 0),
          _category(id: 'c2', name: 'Edible Oils', displayOrder: 1),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atta, Rice & Grains'), findsOneWidget);
    expect(find.text('Edible Oils'), findsOneWidget);
  });

  testWidgets(
    'shows inactive categories too — the admin must be able to re-activate them',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeCategoryRepository([
            _category(id: 'c1', name: 'Active Category'),
            _category(id: 'c2', name: 'Hidden Category', isActive: false),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Category'), findsOneWidget);
      expect(find.text('Hidden Category'), findsOneWidget);
      expect(
        find.text('Inactive'),
        findsOneWidget,
      ); // badge only on the inactive one
    },
  );

  testWidgets(
    'delete asks for confirmation first and only deletes when confirmed',
    (tester) async {
      final repo = FakeCategoryRepository([
        _category(id: 'c1', name: 'Edible Oils'),
      ]);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Delete category?'), findsOneWidget);

      // Backing out must not delete anything.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.deletedIds, isEmpty);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repo.deletedIds, ['c1']);
      expect(find.text('Edible Oils deleted.'), findsOneWidget);
    },
  );

  testWidgets('dragging a category by its handle persists the new order', (
    tester,
  ) async {
    final repo = FakeCategoryRepository([
      _category(id: 'c1', name: 'First', displayOrder: 0),
      _category(id: 'c2', name: 'Second', displayOrder: 1),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    final handle = find.byIcon(Icons.drag_handle_rounded).first;
    await tester.timedDrag(
      handle,
      const Offset(0, 200),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();

    expect(repo.updated, isNotEmpty);
  });
}
