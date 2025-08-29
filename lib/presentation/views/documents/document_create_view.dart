// presentation/views/documents/document_create_view.dart - UPDATED WITH ITEM MANAGEMENT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../viewmodels/item_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../dialogs/add_item_dialog.dart';
import '../../../data/models/document.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/item.dart';

class DocumentCreateView extends StatefulWidget {
  final Document? document; // null for create, existing document for edit
  final Customer? preselectedCustomer;

  const DocumentCreateView({
    super.key, 
    this.document, 
    this.preselectedCustomer,
  });

  @override
  State<DocumentCreateView> createState() => _DocumentCreateViewState();
}

class _DocumentCreateViewState extends State<DocumentCreateView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _numberController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  
  // Form values
  String _selectedType = AppConstants.documentTypes.first;
  String _selectedStatus = AppConstants.documentStatuses.first;
  Customer? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  
  List<DocumentItem> _documentItems = [];
  double _taxRate = AppConstants.defaultTaxRate;

  bool get isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadData();
  }

  void _initializeForm() {
    final document = widget.document;
    
    _numberController = TextEditingController(text: document?.number ?? _generateDocumentNumber());
    _notesController = TextEditingController(text: document?.notes ?? '');
    _termsController = TextEditingController(text: document?.terms ?? AppConstants.paymentTerms.first);
    
    if (document != null) {
      _selectedType = document.type;
      _selectedStatus = document.status;
      _selectedDate = document.date;
      _dueDate = document.dueDate;
      _documentItems = List.from(document.items);
    }
    
    _selectedCustomer = widget.preselectedCustomer;
    
    // Load customer for editing if document exists
    if (document != null && _selectedCustomer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customerViewModel = context.read<CustomerViewModel>();
        final customer = customerViewModel.getCustomerById(document.customerId);
        if (customer != null && mounted) {
          setState(() {
            _selectedCustomer = customer;
          });
        }
      });
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().loadCustomers();
      context.read<ItemViewModel>().loadItems();
    });
  }

  String _generateDocumentNumber() {
    final now = DateTime.now();
    final prefix = _selectedType.substring(0, 3).toUpperCase();
    return '$prefix-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit ${widget.document!.type}' : 'Create Document',
        actions: [
          if (_documentItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: _previewDocument,
            ),
        ],
      ),
      body: Consumer3<DocumentViewModel, CustomerViewModel, ItemViewModel>(
        builder: (context, documentViewModel, customerViewModel, itemViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Document Information Section
                  _buildDocumentInfoSection(customerViewModel),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Items Section
                  _buildItemsSection(itemViewModel),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Summary Section
                  _buildSummarySection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Notes and Terms Section
                  _buildNotesSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Action Buttons
                  _buildActionButtons(documentViewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentInfoSection(CustomerViewModel customerViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Information',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Document Type and Number Row
            Row(
              children: [
                Expanded(
                  child: _buildTypeDropdown(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomTextField(
                    label: 'Document Number *',
                    controller: _numberController,
                    validator: (value) => ValidationUtils.validateRequired(value, 'Document number'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Customer and Status Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildCustomerDropdown(customerViewModel),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatusDropdown(),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Date Row
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Document Date *', _selectedDate, (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDateField('Due Date', _dueDate, (date) {
                    setState(() {
                      _dueDate = date;
                    });
                  }, nullable: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(ItemViewModel itemViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Items (${_documentItems.length})',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(itemViewModel),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 36),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            if (_documentItems.isEmpty)
              _buildEmptyItems()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _documentItems.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildDocumentItemTile(_documentItems[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 48,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No items added yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => _showAddItemDialog(context.read<ItemViewModel>()),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Item'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItemTile(DocumentItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editItem(index),
                    icon: const Icon(Icons.edit, size: 20),
                    color: AppColors.primaryColor,
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    onPressed: () => _removeItem(index),
                    icon: const Icon(Icons.delete, size: 20),
                    color: AppColors.errorColor,
                    tooltip: 'Remove Item',
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  'Qty: ${item.quantity} ${item.unit}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  'Rate: ${CurrencyUtils.formatAmount(item.unitPrice)}',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              if (item.discount > 0)
                Expanded(
                  child: Text(
                    'Discount: ${CurrencyUtils.formatAmount(item.discount)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.errorColor,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  'Total: ${CurrencyUtils.formatAmount(item.total)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTaxAmount(subtotal);
    final total = subtotal + taxAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            _buildSummaryRow('Subtotal', CurrencyUtils.formatAmount(subtotal)),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tax Rate (%)',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: _taxRate.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _taxRate = double.tryParse(value) ?? AppConstants.defaultTaxRate;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            _buildSummaryRow('Tax Amount', CurrencyUtils.formatAmount(taxAmount)),
            const Divider(),
            _buildSummaryRow(
              'Total', 
              CurrencyUtils.formatAmount(total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal 
                ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            amount,
            style: isTotal
              ? AppTextStyles.h4.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                )
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      children: [
        CustomTextField(
          label: 'Notes',
          controller: _notesController,
          maxLines: 3,
          hint: 'Add any additional notes or comments',
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        CustomTextField(
          label: 'Terms & Conditions',
          controller: _termsController,
          maxLines: 3,
          hint: 'Payment terms, delivery conditions, etc.',
        ),
      ],
    );
  }

  Widget _buildActionButtons(DocumentViewModel documentViewModel) {
    return Column(
      children: [
        CustomButton(
          text: isEditing ? 'Update Document' : 'Create Document',
          onPressed: documentViewModel.isLoading ? null : _handleSave,
          isLoading: documentViewModel.isLoading,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        if (_documentItems.isNotEmpty)
          CustomButton(
            text: 'Save as Draft',
            type: ButtonType.outlined,
            onPressed: documentViewModel.isLoading ? null : _saveDraft,
          ),
        
        const SizedBox(height: AppSpacing.sm),
        
        CustomButton(
          text: 'Cancel',
          type: ButtonType.text,
          onPressed: documentViewModel.isLoading ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Type *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: AppConstants.documentTypes.map((type) => 
            DropdownMenuItem(value: type, child: Text(type))
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
                _numberController.text = _generateDocumentNumber();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCustomerDropdown(CustomerViewModel customerViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer *',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Customer>(
          value: _selectedCustomer,
          hint: const Text('Select customer'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: customerViewModel.customers.map((customer) => 
            DropdownMenuItem(
              value: customer, 
              child: Text(customer.name),
            )
          ).toList(),
          onChanged: (customer) {
            setState(() {
              _selectedCustomer = customer;
            });
          },
          validator: (value) => value == null ? 'Please select a customer' : null,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: AppConstants.documentStatuses.map((status) => 
            DropdownMenuItem(value: status, child: Text(status))
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label, 
    DateTime? date, 
    Function(DateTime) onChanged, {
    bool nullable = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date ?? DateTime.now(), onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null 
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date != null 
                        ? AppColors.textPrimaryColor
                        : AppColors.textSecondaryColor,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today),
                if (nullable && date != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        if (label.contains('Due Date')) {
                          _dueDate = null;
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  Future<void> _selectDate(DateTime initialDate, Function(DateTime) onChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      onChanged(picked);
    }
  }

  Future<void> _showAddItemDialog(ItemViewModel itemViewModel) async {
    final result = await showDialog<DocumentItem>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
    
    if (result != null) {
      setState(() {
        // Update the document ID for the item
        final updatedItem = result.copyWith(
          documentId: widget.document?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        );
        _documentItems.add(updatedItem);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _documentItems.removeAt(index);
    });
  }

  Future<void> _editItem(int index) async {
    final item = _documentItems[index];
    final result = await showDialog<DocumentItem>(
      context: context,
      builder: (context) => AddItemDialog(
        documentItem: item,
        isEditMode: true,
      ),
    );
    
    if (result != null) {
      setState(() {
        _documentItems[index] = result;
      });
    }
  }

  double _calculateSubtotal() {
    return _documentItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateTaxAmount(double subtotal) {
    return subtotal * (_taxRate / 100);
  }

  void _previewDocument() {
    if (_selectedCustomer == null || _documentItems.isEmpty) {
      NavigationUtils.showSnackBar(
        context,
        'Please select a customer and add items to preview',
        type: SnackBarType.warning,
      );
      return;
    }
    
    NavigationUtils.showSnackBar(
      context,
      'Document preview will open the generated document',
      type: SnackBarType.info,
    );
  }

  Future<void> _saveDraft() async {
    final draftStatus = 'Draft';
    final originalStatus = _selectedStatus;
    _selectedStatus = draftStatus;
    
    final success = await _handleSave(isDraft: true);
    if (!success) {
      _selectedStatus = originalStatus; // Restore original status on failure
    }
  }

  Future<bool> _handleSave({bool isDraft = false}) async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedCustomer == null) {
      NavigationUtils.showSnackBar(
        context,
        'Please select a customer',
        type: SnackBarType.error,
      );
      return false;
    }

    if (_documentItems.isEmpty) {
      NavigationUtils.showSnackBar(
        context,
        'Please add at least one item',
        type: SnackBarType.error,
      );
      return false;
    }

    final subtotal = _calculateSubtotal();
    final taxAmount = _calculateTaxAmount(subtotal);
    final total = subtotal + taxAmount;

    final document = Document(
      id: widget.document?.id ?? '',
      type: _selectedType,
      number: _numberController.text.trim(),
      customerId: _selectedCustomer!.id,
      date: _selectedDate,
      dueDate: _dueDate,
      status: isDraft ? 'Draft' : _selectedStatus,
      currency: 'USD',
      currencySymbol: '\$',
      items: _documentItems,
      subtotal: subtotal,
      taxAmount: taxAmount,
      total: total,
      notes: _notesController.text.trim(),
      terms: _termsController.text.trim(),
      createdAt: widget.document?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final documentViewModel = context.read<DocumentViewModel>();
    bool success;
    
    if (isEditing) {
      success = await documentViewModel.updateDocument(document);
    } else {
      success = await documentViewModel.createDocument(document);
    }

    if (success && mounted) {
      NavigationUtils.showSnackBar(
        context,
        isEditing 
          ? 'Document updated successfully' 
          : isDraft 
            ? 'Document saved as draft'
            : 'Document created successfully',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
      return true;
    } else if (mounted) {
      NavigationUtils.showSnackBar(
        context,
        documentViewModel.error ?? 'Failed to save document',
        type: SnackBarType.error,
      );
      return false;
    }
    
    return false;
  }
}