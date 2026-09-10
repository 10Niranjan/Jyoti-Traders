import 'package:uuid/uuid.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/weight_rate_slabs.dart';
import 'csv_encoder.dart';

/// One parsed line from a pasted product CSV. Exactly one of [product] /
/// [error] is set — a row either became a valid product ready to create, or
/// it didn't and [error] says why, keyed to [rowNumber] (1-based, counting
/// the header as row 1) so the admin can find and fix it in their sheet.
class BulkImportRow {
  final int rowNumber;
  final ProductEntity? product;
  final String? error;

  const BulkImportRow({required this.rowNumber, this.product, this.error});

  bool get isValid => product != null;
}

const _expectedHeader = ['name', 'category', 'price', 'unit', 'stock', 'description'];

/// Parses pasted CSV/TSV product rows against the live [categories] list (so
/// a typo'd or since-renamed category name is caught here, not as a silent
/// mis-file at save time). Expects a header row naming (in any order):
/// name, category, price, unit, stock, description (description optional) —
/// plus, only for kg products, four optional rate-slab columns:
/// below240g, upto999g, upto2400g, above2400g. Blank lines are skipped.
List<BulkImportRow> parseBulkProductCsv(String csv, List<CategoryEntity> categories) {
  final rows = decodeCsv(csv.trim());
  if (rows.isEmpty) return const [];

  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  final missing = _expectedHeader.where((h) => h != 'description' && !header.contains(h));
  if (missing.isNotEmpty) {
    return [
      BulkImportRow(rowNumber: 1, error: 'Missing required column(s): ${missing.join(', ')}'),
    ];
  }
  int colIndex(String name) => header.indexOf(name);

  final results = <BulkImportRow>[];
  for (var i = 1; i < rows.length; i++) {
    final rowNumber = i + 1;
    final cells = rows[i];
    if (cells.every((c) => c.trim().isEmpty)) continue; // blank line

    String cell(String name) {
      final idx = colIndex(name);
      return (idx == -1 || idx >= cells.length) ? '' : cells[idx].trim();
    }

    final name = cell('name');
    if (name.isEmpty) {
      results.add(BulkImportRow(rowNumber: rowNumber, error: 'Name is required'));
      continue;
    }

    final categoryName = cell('category');
    final categoryMatches = categories.where((c) => c.name.toLowerCase() == categoryName.toLowerCase());
    final category = categoryMatches.isEmpty ? null : categoryMatches.first;
    if (category == null) {
      results.add(BulkImportRow(rowNumber: rowNumber, error: 'Unknown category "$categoryName"'));
      continue;
    }

    final price = double.tryParse(cell('price'));
    if (price == null || price <= 0) {
      results.add(BulkImportRow(rowNumber: rowNumber, error: 'Price must be a positive number'));
      continue;
    }

    final unitMatches = ProductUnit.values.where((u) => u.value == cell('unit').toLowerCase());
    final unit = unitMatches.isEmpty ? null : unitMatches.first;
    if (unit == null) {
      results.add(
        BulkImportRow(
          rowNumber: rowNumber,
          error: 'Unit must be one of: ${ProductUnit.values.map((u) => u.value).join(', ')}',
        ),
      );
      continue;
    }

    final stock = int.tryParse(cell('stock'));
    if (stock == null || stock < 0) {
      results.add(BulkImportRow(rowNumber: rowNumber, error: 'Stock must be a whole number ≥ 0'));
      continue;
    }

    WeightRateSlabs? rateSlabs;
    if (unit == ProductUnit.kg) {
      final below240g = double.tryParse(cell('below240g'));
      final upto999g = double.tryParse(cell('upto999g'));
      final upto2400g = double.tryParse(cell('upto2400g'));
      final above2400g = double.tryParse(cell('above2400g'));
      if (below240g != null && upto999g != null && upto2400g != null && above2400g != null) {
        rateSlabs = WeightRateSlabs(
          below240g: below240g,
          upto999g: upto999g,
          upto2400g: upto2400g,
          above2400g: above2400g,
        );
      }
    }

    results.add(
      BulkImportRow(
        rowNumber: rowNumber,
        product: ProductEntity(
          id: const Uuid().v4(),
          name: name,
          categoryId: category.id,
          imageUrl: '',
          price: Money(price),
          unit: unit,
          stock: stock,
          description: cell('description').isEmpty ? null : cell('description'),
          isActive: true,
          rateSlabs: rateSlabs,
        ),
      ),
    );
  }

  return results;
}
