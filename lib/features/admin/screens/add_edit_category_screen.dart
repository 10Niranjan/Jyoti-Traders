import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/category_entity.dart';
import '../controllers/admin_category_controller.dart';
import '../widgets/product_image_picker_field.dart';

/// Create (when [categoryId] is null) or edit an existing category.
class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;

  const AddEditCategoryScreen({super.key, this.categoryId});

  bool get isEditing => categoryId != null;

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isActive = true;
  int _displayOrder = 0;
  String? _existingIconUrl;
  String? _pickedIconPath;

  /// Guards against re-seeding the form from the stream on every rebuild,
  /// which would clobber whatever the admin has typed so far.
  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _seedFrom(CategoryEntity category) {
    _nameController.text = category.name;
    _isActive = category.isActive;
    _displayOrder = category.displayOrder;
    _existingIconUrl = category.iconUrl;
    _seeded = true;
  }

  Future<void> _pickIcon() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _pickedIconPath = picked.path);
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

    final category = CategoryEntity(
      id: widget.categoryId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      iconUrl: _existingIconUrl ?? '',
      displayOrder: _displayOrder,
      isActive: _isActive,
    );

    final controller = ref.read(adminCategoryControllerProvider.notifier);
    final success = widget.isEditing
        ? await controller.update(category, localIconPath: _pickedIconPath)
        : await controller.create(category, localIconPath: _pickedIconPath);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? '${category.name} updated.' : '${category.name} added.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${ref.read(adminCategoryControllerProvider).error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final saveState = ref.watch(adminCategoryControllerProvider);
    final isSaving = saveState.isLoading;

    if (!widget.isEditing) {
      // New categories go to the end of the list by default; reordering
      // afterwards happens via drag on the list screen.
      final categories = categoriesAsync.valueOrNull;
      if (categories != null) _displayOrder = categories.length;
    } else if (!_seeded) {
      // Seed once from the live category when editing.
      final category = ref.watch(adminCategoryByIdProvider(widget.categoryId!)).valueOrNull;
      if (category != null) _seedFrom(category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Category' : 'Add Category',
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
                pickedPath: _pickedIconPath,
                existingUrl: _existingIconUrl,
                onPick: isSaving ? null : _pickIcon,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                enabled: !isSaving,
                decoration: const InputDecoration(labelText: 'Category name', hintText: 'e.g. Edible Oils'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Category name is required' : null,
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: isSaving ? null : (v) => setState(() => _isActive = v),
                title: Text('Active', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  'Inactive categories stay in your catalog but are hidden from retailers.',
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
                          widget.isEditing ? 'Save Changes' : 'Add Category',
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
