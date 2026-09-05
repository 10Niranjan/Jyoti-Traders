import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../domain/value_objects/weight_rate_slabs.dart';
import '../controllers/admin_category_controller.dart';
import '../controllers/admin_product_controller.dart';
import '../../../shared/widgets/image_picker_field.dart';

/// Create (when [productId] is null) or edit an existing product.
class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// The four per-kg rates, in band order, shown only for kg products.
  late final List<TextEditingController> _rateControllers = [
    TextEditingController(text: WeightRateSlabs.defaults.below240g.toStringAsFixed(0)),
    TextEditingController(text: WeightRateSlabs.defaults.upto999g.toStringAsFixed(0)),
    TextEditingController(text: WeightRateSlabs.defaults.upto2400g.toStringAsFixed(0)),
    TextEditingController(text: WeightRateSlabs.defaults.above2400g.toStringAsFixed(0)),
  ];

  String? _categoryId;
  ProductUnit _unit = ProductUnit.piece;
  bool _isActive = true;
  String? _existingImageUrl;
  String? _pickedImagePath;

  /// Guards against re-seeding the form from the stream on every rebuild,
  /// which would clobber whatever the admin has typed so far.
  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    for (final c in _rateControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _seedFrom(ProductEntity product) {
    _nameController.text = product.name;
    _priceController.text = product.price.amount.toStringAsFixed(2);
    _stockController.text = '${product.stock}';
    _descriptionController.text = product.description ?? '';
    _categoryId = product.categoryId;
    _unit = product.unit;
    _isActive = product.isActive;
    _existingImageUrl = product.imageUrl;
    final slabs = product.rateSlabs;
    if (slabs != null) {
      final rates = [slabs.below240g, slabs.upto999g, slabs.upto2400g, slabs.above2400g];
      for (var i = 0; i < rates.length; i++) {
        _rateControllers[i].text = rates[i].toStringAsFixed(
          rates[i] == rates[i].roundToDouble() ? 0 : 2,
        );
      }
    }
    _seeded = true;
  }

  /// Null unless this is a kg product with four valid rates entered.
  WeightRateSlabs? _slabsFromForm() {
    if (_unit != ProductUnit.kg) return null;
    final rates = _rateControllers
        .map((c) => double.tryParse(c.text.trim()))
        .toList();
    if (rates.any((r) => r == null || r <= 0)) return null;
    return WeightRateSlabs(
      below240g: rates[0]!,
      upto999g: rates[1]!,
      upto2400g: rates[2]!,
      above2400g: rates[3]!,
    );
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImagePath = picked.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t open the gallery: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final slabs = _slabsFromForm();
    final product = ProductEntity(
      id: widget.productId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      categoryId: _categoryId!,
      imageUrl: _existingImageUrl ?? '',
      // A slab-priced product has no single price; keep the small-quantity
      // rate in `price` so anything still reading it shows a sane figure.
      price: slabs != null
          ? Money(slabs.below240g)
          : Money(double.parse(_priceController.text.trim())),
      unit: _unit,
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isActive: _isActive,
      rateSlabs: slabs,
    );

    final controller = ref.read(adminProductControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.update(product, localImagePath: _pickedImagePath)
        : await controller.create(product, localImagePath: _pickedImagePath);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? '${product.name} updated.' : '${product.name} added.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${ref.read(adminProductControllerProvider).error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _pluralUnit(ProductUnit unit) => unit == ProductUnit.box ? 'boxes' : '${unit.value}s';

  @override
  Widget build(BuildContext context) {
    // Unfiltered — a product may already be assigned to a category the
    // admin has since deactivated, and it must still appear so the dropdown
    // has a matching value instead of crashing.
    final categories = ref.watch(adminCategoriesProvider);
    final saveState = ref.watch(adminProductControllerProvider);
    final isSaving = saveState.isLoading;

    // Seed once from the live product when editing.
    if (widget.isEditing && !_seeded) {
      final product = ref.watch(adminProductByIdProvider(widget.productId!)).valueOrNull;
      if (product != null) _seedFrom(product);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerField(
                pickedPath: _pickedImagePath,
                existingUrl: _existingImageUrl,
                onPick: isSaving ? null : _pickImage,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: const InputDecoration(labelText: 'Product name', hintText: 'e.g. Basmati Rice Premium 25kg'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
              ),
              const SizedBox(height: 16),

              categories.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Couldn\'t load categories: $e', style: GoogleFonts.inter(color: AppColors.error)),
                data: (list) => DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in list) DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: isSaving ? null : (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Category is required' : null,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A kg product is priced by the slab table below instead —
                  // removing the field (rather than disabling it) also takes
                  // its validator out of the form.
                  if (_unit != ProductUnit.kg) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        enabled: !isSaving,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹ '),
                        validator: (v) {
                          final parsed = double.tryParse(v?.trim() ?? '');
                          if (parsed == null) return 'Enter a valid price';
                          if (parsed <= 0) return 'Price must be above ₹0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: DropdownButtonFormField<ProductUnit>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: [
                        for (final u in ProductUnit.values) DropdownMenuItem(value: u, child: Text('per ${u.value}')),
                      ],
                      onChanged: isSaving ? null : (v) => setState(() => _unit = v ?? ProductUnit.piece),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_unit == ProductUnit.kg) ...[
                Text(
                  'Rate by quantity (₹ per kg)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'The whole weight is billed at the one rate its band earns.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 10),
                for (final (i, label) in const [
                  'Below 240g',
                  '240g – 999g',
                  '1kg – 2.4kg',
                  'Above 2.4kg',
                ].indexed) ...[
                  TextFormField(
                    controller: _rateControllers[i],
                    enabled: !isSaving,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    decoration: InputDecoration(
                      labelText: label,
                      prefixText: '₹ ',
                      suffixText: '/kg',
                      isDense: true,
                    ),
                    validator: (v) {
                      final parsed = double.tryParse(v?.trim() ?? '');
                      if (parsed == null) return 'Enter a rate for $label';
                      if (parsed <= 0) return 'Rate must be above ₹0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
              ],

              TextFormField(
                controller: _stockController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Stock quantity',
                  helperText: _unit == ProductUnit.kg ? 'In kilograms' : 'In ${_pluralUnit(_unit)}',
                ),
                validator: (v) {
                  final parsed = int.tryParse(v?.trim() ?? '');
                  if (parsed == null) return 'Enter a valid stock quantity';
                  if (parsed < 0) return 'Stock cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                enabled: !isSaving,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile(
                    value: _isActive,
                    onChanged: isSaving ? null : (v) => setState(() => _isActive = v),
                    title: Text('Active', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      'Inactive products stay in your catalog but are hidden from retailers.',
                      style: GoogleFonts.inter(fontSize: 11.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Add Product',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

