// presentation/views/documents/document_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/document.dart';
import '../../../app/app.dart';

class DocumentView extends StatefulWidget {
  final Document document;

  const DocumentView({super.key, required this.document});

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.document.number,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printDocument,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Document'),
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Export as PDF'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.errorColor),
                  title: Text('Delete Document', 
                    style: TextStyle(color: AppColors.errorColor)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<DocumentViewModel, AuthViewModel>(
        builder: (context, documentViewModel, authViewModel, child) {
          final customer = documentViewModel.getCustomerById(widget.document.customerId);
          final user = authViewModel.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Header
                _buildDocumentHeader(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Business & Customer Info
                _buildBusinessCustomerInfo(user?.settings.businessInfo, customer),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Document Items
                _buildItemsSection(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Summary
                _buildSummarySection(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Notes and Terms
                if (widget.document.notes?.isNotEmpty == true ||
                    widget.document.terms?.isNotEmpty == true)
                  _buildNotesTermsSection(),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
                        widget.document.type.toUpperCase(),
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.document.number,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatDate(widget.document.date),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.document.dueDate != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                        Text(
                          AppDateUtils.formatDate(widget.document.dueDate!),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppDateUtils.isOverdue(widget.document.dueDate)
                                ? AppColors.errorColor
                                : AppColors.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (widget.document.status.toLowerCase()) {
      case 'paid':
        statusColor = AppColors.successColor;
        break;
      case 'overdue':
        statusColor = AppColors.errorColor;
        break;
      case 'pending':
      case 'sent':
        statusColor = AppColors.warningColor;
        break;
      default:
        statusColor = AppColors.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        widget.document.status,
        style: AppTextStyles.bodySmall.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBusinessCustomerInfo(businessInfo, customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (businessInfo != null) ...[
                    Text(
                      businessInfo.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (businessInfo.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(businessInfo.address, style: AppTextStyles.bodySmall),
                    ],
                    if (businessInfo.city.isNotEmpty) ...[
                      Text('${businessInfo.city}, ${businessInfo.state} ${businessInfo.zipCode}', 
                        style: AppTextStyles.bodySmall),
                    ],
                    if (businessInfo.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(businessInfo.phone, style: AppTextStyles.bodySmall),
                    ],
                    if (businessInfo.email.isNotEmpty) ...[
                      Text(businessInfo.email, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: AppSpacing.lg),
            
            // Customer Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (customer != null) ...[
                    Text(
                      customer.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (customer.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(customer.address, style: AppTextStyles.bodySmall),
                    ],
                    if (customer.city.isNotEmpty) ...[
                      Text('${customer.city}, ${customer.state} ${customer.zipCode}', 
                        style: AppTextStyles.bodySmall),
                    ],
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(customer.phone, style: AppTextStyles.bodySmall),
                    ],
                    if (customer.email.isNotEmpty) ...[
                      Text(customer.email, style: AppTextStyles.bodySmall),
                    ],
                  ] else ...[
                    Text(
                      'Customer not found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.errorColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Items Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Description',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Qty',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Rate',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Amount',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            
            // Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.document.items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.document.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.quantity} ${item.unit}',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyUtils.formatAmount(
                            item.unitPrice, 
                            widget.document.currencySymbol,
                          ),
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyUtils.formatAmount(
                            item.total, 
                            widget.document.currencySymbol,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildSummaryRow(
              'Subtotal', 
              CurrencyUtils.formatAmount(
                widget.document.subtotal, 
                widget.document.currencySymbol,
              ),
            ),
            
            if (widget.document.discountAmount > 0)
              _buildSummaryRow(
                'Discount', 
                '- ${CurrencyUtils.formatAmount(
                  widget.document.discountAmount, 
                  widget.document.currencySymbol,
                )}',
              ),
            
            _buildSummaryRow(
              'Tax', 
              CurrencyUtils.formatAmount(
                widget.document.taxAmount, 
                widget.document.currencySymbol,
              ),
            ),
            
            const Divider(),
            
            _buildSummaryRow(
              'Total', 
              CurrencyUtils.formatAmount(
                widget.document.total, 
                widget.document.currencySymbol,
              ),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal 
                ? AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)
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

  Widget _buildNotesTermsSection() {
    return Column(
      children: [
        if (widget.document.notes?.isNotEmpty == true)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.document.notes!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        
        if (widget.document.notes?.isNotEmpty == true && 
            widget.document.terms?.isNotEmpty == true)
          const SizedBox(height: AppSpacing.md),
        
        if (widget.document.terms?.isNotEmpty == true)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.document.terms!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareDocument,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _printDocument,
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _editDocument,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Document'),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editDocument();
        break;
      case 'duplicate':
        _duplicateDocument();
        break;
      case 'pdf':
        _exportToPDF();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _editDocument() {
    NavigationService.pushNamed(
      Routes.documentEdit,
      arguments: widget.document,
    );
  }

  void _shareDocument() {
    NavigationUtils.showSnackBar(
      context,
      'Share functionality will be implemented',
      type: SnackBarType.info,
    );
  }

  void _printDocument() {
    NavigationUtils.showSnackBar(
      context,
      'Print functionality will be implemented',
      type: SnackBarType.info,
    );
  }

  void _duplicateDocument() {
    NavigationUtils.showSnackBar(
      context,
      'Document duplicated successfully',
      type: SnackBarType.success,
    );
  }

  void _exportToPDF() {
    NavigationUtils.showSnackBar(
      context,
      'PDF export functionality will be implemented',
      type: SnackBarType.info,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await NavigationUtils.showConfirmDialog(
      context,
      title: 'Delete Document',
      message: 'Are you sure you want to delete ${widget.document.number}? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<DocumentViewModel>().deleteDocument(widget.document.id);
      if (success && mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Document deleted successfully',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      }
    }
  }
}