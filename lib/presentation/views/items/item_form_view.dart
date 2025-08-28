// presentation/views/items/item_form_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/item_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/item.dart';

class ItemFormView extends StatefulWidget {
  final Item? item; // null for create, existing item for edit

  const ItemFormView({super.key, this.item});

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _taxRateController;
  
  // Dropdown values
  String _selectedUnit = AppConstants.itemUnits.first;
  String? _selectedCategory;
  
  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final item = widget.item;
    
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _priceController = TextEditingController(text: item?.price.toStringAsFixed(2) ?? '0.00');
    _taxRateController = TextEditingController(text: item?.taxRate.toStringAsFixed(2) ?? '0.00');
    
    if (item != null) {
      _selectedUnit = item.unit;
      _selectedCategory = item.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Item' : 'Add Item',
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, itemViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Information Section
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Item Name *',
                    controller: _nameController,
                    validator: (value) => ValidationUtils.validateRequired(value, 'Item name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Category Dropdown
                  _buildCategoryDropdown(itemViewModel),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Pricing Section
                  _buildSectionHeader('Pricing & Tax'),
                  const SizedBox(height: AppSpacing.md),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: 'Price *',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: ValidationUtils.validateAmount,
                          prefixText: '\$ ',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildUnitDropdown(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Tax Rate (%)',
                    controller: _taxRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    suffixText: '%',
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Action Buttons
                  CustomButton(
                    text: isEditing ? 'Update Item' : 'Create Item',
                    onPressed: itemViewModel.isLoading ? null : _handleSave,
                    isLoading: itemViewModel.isLoading,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomButton(
                    text: 'Cancel',
                    type: ButtonType.outlined,
                    onPressed: itemViewModel.isLoading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryDropdown(ItemViewModel viewModel) {
    final categories = viewModel.categories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          hint: const Text('Select category'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('No category'),
            ),
            ...categories.map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            )),
            const DropdownMenuItem<String>(
              value: '_new_category',
              child: Text('+ Add new category'),
            ),
          ],
          onChanged: (value) {
            if (value == '_new_category') {
              _showAddCategoryDialog();
            } else {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUnit,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: AppConstants.itemUnits.map((unit) => DropdownMenuItem<String>(
            value: unit,
            child: Text(unit),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedUnit = value;
              });
            }
          },
          validator: (value) => ValidationUtils.validateRequired(value, 'Unit'),
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final categoryController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (categoryController.text.trim().isNotEmpty) {
                Navigator.pop(context, categoryController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final itemViewModel = context.read<ItemViewModel>();
    final item = Item(
      id: widget.item?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      taxRate: double.tryParse(_taxRateController.text) ?? 0.0,
      unit: _selectedUnit,
      category: _selectedCategory?.isNotEmpty == true ? _selectedCategory : null,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await itemViewModel.updateItem(item);
    } else {
      success = await itemViewModel.createItem(item);
    }

    if (success && mounted) {
      NavigationUtils.showSnackBar(
        context,
        isEditing ? 'Item updated successfully' : 'Item created successfully',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else if (mounted) {
      NavigationUtils.showSnackBar(
        context,
        itemViewModel.error ?? 'Failed to save item',
        type: SnackBarType.error,
      );
    }
  }
}