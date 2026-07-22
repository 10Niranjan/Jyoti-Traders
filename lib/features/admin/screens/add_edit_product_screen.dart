import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../features/home/controllers/home_controller.dart';
import '../controllers/admin_product_controller.dart';
import '../widgets/product_image_picker_field.dart';

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
    _seeded = true;
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

    final product = ProductEntity(
      id: widget.productId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      categoryId: _categoryId!,
      imageUrl: _existingImageUrl ?? '',
      price: Money(double.parse(_priceController.text.trim())),
      unit: _unit,
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isActive: _isActive,
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

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImagePickerField(
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

              TextFormField(
                controller: _stockController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Stock quantity'),
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

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: isSaving ? null : (v) => setState(() => _isActive = v),
                title: Text('Active', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  'Inactive products stay in your catalog but are hidden from retailers.',
                  style: GoogleFonts.inter(fontSize: 11.5),
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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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

