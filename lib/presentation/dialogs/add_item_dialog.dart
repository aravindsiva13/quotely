// lib/presentation/dialogs/add_item_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/constants/app_constants.dart';
import '../viewmodels/item_viewmodel.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/custom_button.dart';
import '../../data/models/item.dart';
import '../../data/models/document.dart';

class AddItemDialog extends StatefulWidget {
  final DocumentItem? documentItem; // For editing existing document items
  final bool isEditMode;

  const AddItemDialog({
    super.key,
    this.documentItem,
    this.isEditMode = false,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  
  // Selected item from existing items
  Item? _selectedItem;
  
  // Form controllers for custom item
  final _customNameController = TextEditingController();
  final _customDescriptionController = TextEditingController();
  final _customPriceController = TextEditingController();
  final _customTaxRateController = TextEditingController();
  String _customUnit = AppConstants.itemUnits.first;
  
  // Document item properties
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
    
    // Load existing data if editing
    if (widget.isEditMode && widget.documentItem != null) {
      _loadExistingItem();
    }
    
    // Load items when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
    });
  }

  void _loadExistingItem() {
    final docItem = widget.documentItem!;
    _quantityController.text = docItem.quantity.toString();
    _discountController.text = docItem.discount.toString();
    
    // Try to find the item in existing items
    final itemViewModel = context.read<ItemViewModel>();
    _selectedItem = itemViewModel.getItemById(docItem.itemId);
    
    if (_selectedItem == null) {
      // Item doesn't exist in catalog, load as custom item
      _tabController.index = 1; // Switch to custom tab
      _customNameController.text = docItem.name;
      _customDescriptionController.text = docItem.description;
      _customPriceController.text = docItem.unitPrice.toString();
      _customTaxRateController.text = docItem.taxRate.toString();
      _customUnit = docItem.unit;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customNameController.dispose();
    _customDescriptionController.dispose();
    _customPriceController.dispose();
    _customTaxRateController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isEditMode ? 'Edit Item' : 'Add Item',
                      style: AppTextStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.inventory),
                  text: 'Existing Items',
                ),
                Tab(
                  icon: Icon(Icons.add_box),
                  text: 'Custom Item',
                ),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExistingItemsTab(),
                  _buildCustomItemTab(),
                ],
              ),
            ),
            
            // Footer with calculations and buttons
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingItemsTab() {
    return Consumer<ItemViewModel>(
      builder: (context, itemViewModel, child) {
        if (itemViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (itemViewModel.items.isEmpty) {
          return _buildEmptyItemsState();
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: itemViewModel.searchItems,
              ),
            ),
            
            // Items list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: itemViewModel.filteredItems.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = itemViewModel.filteredItems[index];
                  final isSelected = _selectedItem?.id == item.id;
                  
                  return ListTile(
                    selected: isSelected,
                    leading: CircleAvatar(
                      backgroundColor: isSelected 
                        ? AppColors.primaryColor 
                        : AppColors.backgroundColor,
                      child: Icon(
                        Icons.inventory_2,
                        color: isSelected 
                          ? Colors.white 
                          : AppColors.textSecondaryColor,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              CurrencyUtils.formatAmount(item.price),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Text(' per ${item.unit}'),
                            if (item.category != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: isSelected 
                      ? const Icon(Icons.check_circle, color: AppColors.successColor)
                      : null,
                    onTap: () {
                      setState(() {
                        _selectedItem = isSelected ? null : item;
                      });
                    },
                  );
                },
              ),
            ),
            
            // Quantity and discount section for selected item
            if (_selectedItem != null) _buildItemDetailsSection(),
          ],
        );
      },
    );
  }

  Widget _buildCustomItemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Item Name *',
              controller: _customNameController,
              validator: (value) => ValidationUtils.validateRequired(value, 'Item name'),
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            CustomTextField(
              label: 'Description',
              controller: _customDescriptionController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    label: 'Unit Price *',
                    controller: _customPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: ValidationUtils.validateAmount,
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildUnitDropdown(),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            CustomTextField(
              label: 'Tax Rate (%)',
              controller: _customTaxRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              suffixText: '%',
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quantity and discount section
            _buildItemDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _customUnit,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: AppConstants.itemUnits.map((unit) => DropdownMenuItem(
            value: unit,
            child: Text(unit),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _customUnit = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildItemDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Details',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Quantity *',
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: ValidationUtils.validateQuantity,
                  onChanged: (_) => setState(() {}), // Trigger rebuild for calculations
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomTextField(
                  label: 'Discount (%)',
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  suffixText: '%',
                  onChanged: (_) => setState(() {}), // Trigger rebuild for calculations
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 64,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No items in catalog',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first item using the Custom Item tab',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final calculations = _calculateTotals();
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // Calculations
          if (_hasValidItem() && _hasValidQuantity()) ...[
            _buildCalculationRow('Unit Price', calculations['unitPrice']!),
            _buildCalculationRow('Quantity', calculations['quantity']!),
            if (calculations['discount'] != '\$0.00')
              _buildCalculationRow('Discount', calculations['discount']!),
            const Divider(),
            _buildCalculationRow('Total', calculations['total']!, isTotal: true),
            const SizedBox(height: AppSpacing.md),
          ],
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  type: ButtonType.outlined,
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomButton(
                  text: widget.isEditMode ? 'Update' : 'Add Item',
                  onPressed: _isLoading ? null : _handleAddItem,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
              ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
              ? AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                )
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateTotals() {
    double unitPrice = 0.0;
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    double discountPercent = double.tryParse(_discountController.text) ?? 0.0;
    
    if (_currentTab == 0 && _selectedItem != null) {
      // Using existing item
      unitPrice = _selectedItem!.price;
    } else if (_currentTab == 1) {
      // Using custom item
      unitPrice = double.tryParse(_customPriceController.text) ?? 0.0;
    }
    
    double subtotal = unitPrice * quantity;
    double discountAmount = subtotal * (discountPercent / 100);
    double total = subtotal - discountAmount;
    
    return {
      'unitPrice': CurrencyUtils.formatAmount(unitPrice),
      'quantity': quantity.toString(),
      'discount': CurrencyUtils.formatAmount(discountAmount),
      'total': CurrencyUtils.formatAmount(total),
    };
  }

  bool _hasValidItem() {
    if (_currentTab == 0) {
      return _selectedItem != null;
    } else {
      return _customNameController.text.trim().isNotEmpty &&
             _customPriceController.text.trim().isNotEmpty;
    }
  }

  bool _hasValidQuantity() {
    final quantity = double.tryParse(_quantityController.text);
    return quantity != null && quantity > 0;
  }

  Future<void> _handleAddItem() async {
    if (!_hasValidItem() || !_hasValidQuantity()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an item and enter valid quantity'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }
    
    if (_currentTab == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentItem documentItem;
      
      if (_currentTab == 0 && _selectedItem != null) {
        // Using existing item
        final item = _selectedItem!;
        documentItem = _createDocumentItem(
          itemId: item.id,
          name: item.name,
          description: item.description,
          unitPrice: item.price,
          taxRate: item.taxRate,
          unit: item.unit,
        );
      } else {
        // Using custom item - create new item first if needed
        String itemId = '';
        final itemName = _customNameController.text.trim();
        final unitPrice = double.tryParse(_customPriceController.text) ?? 0.0;
        
        // Check if we should save this as a catalog item
        final shouldSaveToCart = await _showSaveToCatalogDialog();
        
        if (shouldSaveToCart) {
          final newItem = Item(
            id: '', // Will be generated by repository
            name: itemName,
            description: _customDescriptionController.text.trim(),
            price: unitPrice,
            taxRate: double.tryParse(_customTaxRateController.text) ?? 0.0,
            unit: _customUnit,
            createdAt: DateTime.now(),
          );
          
          final itemViewModel = context.read<ItemViewModel>();
          final success = await itemViewModel.createItem(newItem);
          
          if (success) {
            // Find the created item to get its ID
            final createdItem = itemViewModel.items
                .where((item) => item.name == itemName)
                .first;
            itemId = createdItem.id;
          }
        }
        
        documentItem = _createDocumentItem(
          itemId: itemId,
          name: itemName,
          description: _customDescriptionController.text.trim(),
          unitPrice: unitPrice,
          taxRate: double.tryParse(_customTaxRateController.text) ?? 0.0,
          unit: _customUnit,
        );
      }
      
      // Return the created document item
      if (mounted) {
        Navigator.pop(context, documentItem);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DocumentItem _createDocumentItem({
    required String itemId,
    required String name,
    required String description,
    required double unitPrice,
    required double taxRate,
    required String unit,
  }) {
    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final discountPercent = double.tryParse(_discountController.text) ?? 0.0;
    
    final subtotal = unitPrice * quantity;
    final discountAmount = subtotal * (discountPercent / 100);
    final total = subtotal - discountAmount;
    
    return DocumentItem(
      id: widget.documentItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: '', // Will be set by the parent
      itemId: itemId,
      name: name,
      description: description,
      quantity: quantity,
      unitPrice: unitPrice,
      discount: discountAmount,
      taxRate: taxRate,
      total: total,
      unit: unit,
    );
  }

  Future<bool> _showSaveToCatalogDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save to Catalog'),
        content: const Text(
          'Would you like to save this item to your catalog for future use?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Save'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}