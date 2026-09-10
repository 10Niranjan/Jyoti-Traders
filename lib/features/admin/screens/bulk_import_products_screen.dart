import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/bulk_product_import.dart';
import '../../../domain/entities/category_entity.dart';
import '../controllers/admin_category_controller.dart';
import '../controllers/admin_product_controller.dart';

/// Paste-a-CSV bulk product creation — no file picker involved (not on
/// rules.md's approved package list, and a paste box needs no dependency at
/// all) since an admin populating 6–10 categories' worth of products from a
/// spreadsheet just needs to copy cells out and paste them here.
class BulkImportProductsScreen extends ConsumerStatefulWidget {
  const BulkImportProductsScreen({super.key});

  @override
  ConsumerState<BulkImportProductsScreen> createState() => _BulkImportProductsScreenState();
}

class _BulkImportProductsScreenState extends ConsumerState<BulkImportProductsScreen> {
  final _csvController = TextEditingController();
  List<BulkImportRow>? _parsed;
  bool _isImporting = false;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  void _preview(List<CategoryEntity> categories) {
    final rows = parseBulkProductCsv(_csvController.text, categories);
    setState(() => _parsed = rows);
  }

  Future<void> _import() async {
    final rows = _parsed;
    if (rows == null) return;
    setState(() => _isImporting = true);

    var created = 0;
    var failed = 0;
    for (final row in rows.where((r) => r.isValid)) {
      final ok = await ref.read(adminProductControllerProvider.notifier).create(row.product!);
      if (ok) {
        created++;
      } else {
        failed++;
      }
    }

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _parsed = null;
      _csvController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed == 0 ? '$created product(s) created.' : '$created product(s) created, $failed failed.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final parsed = _parsed;
    final validCount = parsed?.where((r) => r.isValid).length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Bulk Import Products', style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste rows copied from a spreadsheet. Header row required: '
              'name, category, price, unit, stock, description (description optional). '
              'Unit is one of: piece, box, litre, kg. For a kg product, add four more '
              'columns to price it by weight: below240g, upto999g, upto2400g, above2400g '
              '— leave them out for a flat per-unit price.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _csvController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.robotoMono(fontSize: 12),
                // The Preview button's enabled state and the stale-preview
                // reset below both depend on this text, and a plain
                // TextField doesn't rebuild its parent on its own — without
                // this, editing the text after a Preview never re-enables
                // it or clears results parsed from what used to be there.
                onChanged: (_) => setState(() => _parsed = null),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Could not load categories: $e'),
              data: (categories) => Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _csvController.text.trim().isEmpty ? null : () => _preview(categories),
                      child: const Text('Preview'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: (validCount > 0 && !_isImporting) ? _import : null,
                      child: _isImporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Import $validCount'),
                    ),
                  ),
                ],
              ),
            ),
            if (parsed != null) ...[
              const SizedBox(height: 12),
              Expanded(
                flex: 3,
                child: ListView.separated(
                  itemCount: parsed.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = parsed[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        row.isValid ? Icons.check_circle_outline : Icons.error_outline,
                        color: row.isValid ? AppColors.success : AppColors.error,
                      ),
                      title: Text(
                        row.isValid ? row.product!.name : 'Row ${row.rowNumber}',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      subtitle: row.isValid ? null : Text(row.error!, style: const TextStyle(color: AppColors.error)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
