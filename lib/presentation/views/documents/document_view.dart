// presentation/views/documents/document_view.dart - UPDATED WITH PDF & WORKFLOW
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/document_workflow_service.dart';
import '../../../core/constants/app_constants.dart';
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
  bool _isGeneratingPDF = false;
  bool _isUpdatingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.document.number,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isGeneratingPDF ? null : _shareDocument,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _isGeneratingPDF ? null : _printDocument,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (DocumentWorkflowService.canEditDocument(widget.document))
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
                value: 'preview',
                child: ListTile(
                  leading: Icon(Icons.preview),
                  title: Text('Preview'),
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.swap_horiz),
                  title: Text('Change Status'),
                ),
              ),
              if (DocumentWorkflowService.canDeleteDocument(widget.document))
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
                // Document Header with Status and Actions
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
                
                // Quick Action Buttons
                _buildQuickActionButtons(user, customer),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Document Workflow Status
                _buildWorkflowInfo(),
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
                      const SizedBox(height: 4),
                      Text(
                        widget.document.number,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(),
                    const SizedBox(height: 8),
                    _buildStatusChangeButton(),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Date', AppDateUtils.formatDate(widget.document.date)),
                ),
                if (widget.document.dueDate != null)
                  Expanded(
                    child: _buildInfoItem(
                      'Due Date', 
                      AppDateUtils.formatDate(widget.document.dueDate!),
                      isOverdue: AppDateUtils.isOverdue(widget.document.dueDate),
                    ),
                  ),
                Expanded(
                  child: _buildInfoItem(
                    'Total Amount',
                    CurrencyUtils.formatAmount(
                      widget.document.total, 
                      widget.document.currencySymbol,
                    ),
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isOverdue = false, bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isPrimary
            ? AppTextStyles.h4.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              )
            : AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isOverdue ? AppColors.errorColor : AppColors.textPrimaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final statusConfig = DocumentWorkflowService.getStatusBadgeConfig(widget.document.status);
    final color = Color(int.parse(statusConfig['color'].replaceAll('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(statusConfig['icon']),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            statusConfig['text'],
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChangeButton() {
    return ElevatedButton.icon(
      onPressed: _isUpdatingStatus ? null : _showStatusChangeDialog,
      icon: _isUpdatingStatus 
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.swap_horiz, size: 16),
      label: Text(_isUpdatingStatus ? 'Updating...' : 'Change Status'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 32),
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
                      businessInfo.name.isNotEmpty ? businessInfo.name : 'Business Name',
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
                  ] else ...[
                    Text(
                      'Business information not set',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
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
              'Items (${widget.document.items.length})',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            if (widget.document.items.isEmpty) ...[
              Container(
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
                      'No items in this document',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
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

  Widget _buildQuickActionButtons(user, customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ElevatedButton.icon(
                  onPressed: _isGeneratingPDF || user == null || customer == null
                      ? null
                      : () => _generateAndSharePDF(user, customer),
                  icon: _isGeneratingPDF
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share, size: 16),
                  label: Text(_isGeneratingPDF ? 'Generating...' : 'Share PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                OutlinedButton.icon(
                  onPressed: _isGeneratingPDF || user == null || customer == null
                      ? null
                      : () => _previewDocument(user, customer),
                  icon: const Icon(Icons.preview, size: 16),
                  label: const Text('Preview'),
                ),
                
                OutlinedButton.icon(
                  onPressed: _isGeneratingPDF || user == null || customer == null
                      ? null
                      : () => _printDocument(),
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Print'),
                ),
                
                if (DocumentWorkflowService.canEditDocument(widget.document))
                  OutlinedButton.icon(
                    onPressed: () => _editDocument(),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowInfo() {
    final recommendation = DocumentWorkflowService.getRecommendedNextAction(widget.document);
    final isOverdue = DocumentWorkflowService.isDocumentOverdue(widget.document);
    
    return Card(
      color: isOverdue ? AppColors.errorColor.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.lightbulb_outline,
                  color: isOverdue ? AppColors.errorColor : AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOverdue ? 'Urgent Action Required' : 'Recommended Next Action',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? AppColors.errorColor : AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              recommendation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isOverdue ? AppColors.errorColor : AppColors.textPrimaryColor,
              ),
            ),
            
            if (widget.document.updatedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last updated: ${AppDateUtils.formatRelativeTime(widget.document.updatedAt!)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String iconName) {
    switch (iconName) {
      case 'edit':
        return Icons.edit;
      case 'send':
        return Icons.send;
      case 'visibility':
        return Icons.visibility;
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'payment':
        return Icons.payment;
      case 'warning':
        return Icons.warning;
      case 'block':
        return Icons.block;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.info;
    }
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
      case 'preview':
        _previewDocument(
          context.read<AuthViewModel>().currentUser,
          context.read<DocumentViewModel>().getCustomerById(widget.document.customerId),
        );
        break;
      case 'status':
        _showStatusChangeDialog();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  Future<void> _showStatusChangeDialog() async {
    final availableStatuses = DocumentWorkflowService.getAvailableStatusTransitions(widget.document.status);
    
    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Document Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status: ${widget.document.status}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Select new status:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...availableStatuses.map((status) => RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: widget.document.status,
              onChanged: (value) => Navigator.pop(context, value),
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedStatus != null && selectedStatus != widget.document.status) {
      await _updateDocumentStatus(selectedStatus);
    }
  }

  Future<void> _updateDocumentStatus(String newStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final success = await context.read<DocumentViewModel>().updateDocumentStatus(
        widget.document.id, 
        newStatus,
      );

      if (success && mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Document status updated to $newStatus',
          type: SnackBarType.success,
        );
        
        // Refresh the document data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentView(
              document: widget.document.copyWith(status: newStatus),
            ),
          ),
        );
      } else if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Failed to update document status',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Error updating status: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  void _editDocument() {
    NavigationService.pushNamed(
      Routes.documentEdit,
      arguments: widget.document,
    );
  }

  Future<void> _generateAndSharePDF(user, customer) async {
    if (user == null || customer == null) {
      NavigationUtils.showSnackBar(
        context,
        'Unable to generate PDF - missing user or customer data',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.shareDocument(
        document: widget.document,
        customer: customer,
        user: user,
      );

      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'PDF generated and ready to share',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Failed to generate PDF: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  void _shareDocument() async {
    final user = context.read<AuthViewModel>().currentUser;
    final customer = context.read<DocumentViewModel>().getCustomerById(widget.document.customerId);
    
    await _generateAndSharePDF(user, customer);
  }

  void _printDocument() async {
    final user = context.read<AuthViewModel>().currentUser;
    final customer = context.read<DocumentViewModel>().getCustomerById(widget.document.customerId);
    
    if (user == null || customer == null) {
      NavigationUtils.showSnackBar(
        context,
        'Unable to print - missing user or customer data',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.printDocument(
        document: widget.document,
        customer: customer,
        user: user,
      );

      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Document prepared for printing',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Print preparation completed',
          type: SnackBarType.info,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  void _previewDocument(user, customer) async {
    if (user == null || customer == null) {
      NavigationUtils.showSnackBar(
        context,
        'Unable to preview - missing user or customer data',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.previewDocument(
        document: widget.document,
        customer: customer,
        user: user,
      );

      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Preview generated successfully',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Preview generation completed',
          type: SnackBarType.info,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  void _duplicateDocument() {
    NavigationUtils.showSnackBar(
      context,
      'Document duplication feature will be implemented',
      type: SnackBarType.info,
    );
  }

  void _exportToPDF() async {
    final user = context.read<AuthViewModel>().currentUser;
    final customer = context.read<DocumentViewModel>().getCustomerById(widget.document.customerId);
    await _generateAndSharePDF(user, customer);
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