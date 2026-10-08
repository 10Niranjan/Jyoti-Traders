import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/domain/repositories/category_repository.dart';
import 'package:traders_retailer/features/admin/screens/add_edit_category_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> created = [];
  final List<CategoryEntity> updated = [];

  FakeCategoryRepository([this.categories = const []]);

  @override
  Stream<List<CategoryEntity>> watchCategories() => Stream.value(categories);

  @override
  Future<void> createCategory(CategoryEntity category) async =>
      created.add(category);

  @override
  Future<void> updateCategory(CategoryEntity category) async =>
      updated.add(category);

  @override
  Future<void> deleteCategory(String categoryId) async {}
}

Widget _wrap(FakeCategoryRepository repo, {String? categoryId}) =>
    ProviderScope(
      overrides: [categoryRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddEditCategoryScreen(categoryId: categoryId),
      ),
    );

void main() {
  useTallTestViewport();

  testWidgets('create mode shows an empty "Add Category" form', (tester) async {
    await tester.pumpWidget(_wrap(FakeCategoryRepository()));
    await tester.pumpAndSettle();

    expect(
      find.text('Add Category'),
      findsNWidgets(2),
    ); // app bar + submit button
  });

  testWidgets('blocks submission when the name is empty', (tester) async {
    final repo = FakeCategoryRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    // The Save button is proactively disabled while the name is empty,
    // matching the Figma reference — greyed out, not tappable.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Add Category'),
    );
    expect(button.onPressed, isNull);
    expect(repo.created, isEmpty);
  });

  testWidgets('creates a category placed after the existing ones', (
    tester,
  ) async {
    final repo = FakeCategoryRepository([
      CategoryEntity(
        id: 'c1',
        name: 'Existing',
        iconUrl: '',
        displayOrder: 0,
        isActive: true,
      ),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Category name'),
      'Edible Oils',
    );
    await tester
        .pump(); // lets the Save button's enabled state catch up to the typed name
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Category'));
    await tester.pumpAndSettle();

    expect(repo.created, hasLength(1));
    final saved = repo.created.single;
    expect(saved.name, 'Edible Oils');
    expect(saved.displayOrder, 1); // appended after the one existing category
    expect(saved.isActive, isTrue);
    expect(saved.id, isNotEmpty); // generated
  });

  testWidgets(
    'edit mode pre-fills the form from the existing category and updates it',
    (tester) async {
      final existing = CategoryEntity(
        id: 'c1',
        name: 'Edible Oils',
        iconUrl: '',
        displayOrder: 2,
        isActive: true,
      );
      final repo = FakeCategoryRepository([existing]);

      await tester.pumpWidget(_wrap(repo, categoryId: 'c1'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Edible Oils'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Edible Oils'),
        'Edible Oils (New)',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(repo.updated, hasLength(1));
      expect(
        repo.updated.single.id,
        'c1',
      ); // keeps its id rather than creating a duplicate
      expect(repo.updated.single.name, 'Edible Oils (New)');
      expect(
        repo.updated.single.displayOrder,
        2,
      ); // unchanged by the edit form — reorder is drag-only
      expect(repo.created, isEmpty);
    },
  );

  testWidgets('turning off Active persists isActive false', (tester) async {
    final repo = FakeCategoryRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Category name'),
      'Snacks',
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Category'));
    await tester.pumpAndSettle();

    expect(repo.created.single.isActive, isFalse);
  });
}
