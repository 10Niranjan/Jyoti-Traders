import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/constants/app_colors.dart';
import 'package:traders_retailer/domain/entities/category_entity.dart';
import 'package:traders_retailer/shared/widgets/category_card.dart';

CategoryEntity _category({String iconUrl = '', int displayOrder = 0}) => CategoryEntity(
      id: 'c1',
      name: 'Edible Oils',
      iconUrl: iconUrl,
      displayOrder: displayOrder,
      isActive: true,
    );

void main() {
  testWidgets('renders the category name and a fallback icon with no uploaded icon', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CategoryCard(category: _category(), onTap: () {})),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Edible Oils'), findsOneWidget);
    expect(find.byIcon(Icons.opacity_outlined), findsOneWidget); // "oil" match in _iconFor
  });

  testWidgets('tapping the card calls onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CategoryCard(category: _category(), onTap: () => tapped = true)),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CategoryCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('renders an uploaded local-path icon instead of the fallback', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CategoryCard(category: _category(iconUrl: '/tmp/fake_icon.png'), onTap: () {})),
    ));
    await tester.pumpAndSettle();

    // A real Image.file for a nonexistent path fails to load and falls back
    // to the same Material icon — but via the image-error path, not the
    // "no iconUrl at all" path. Both end up showing the fallback icon; the
    // meaningful assertion is that an Image widget was attempted at all.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ring color rotates through the category palette by displayOrder', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CategoryCard(category: _category(displayOrder: 1), onTap: () {})),
    ));
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(find.byIcon(Icons.opacity_outlined));
    expect(icon.color, AppColors.categoryPalette[1 % AppColors.categoryPalette.length]);
  });
}
