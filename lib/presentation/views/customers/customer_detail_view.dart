// presentation/views/customers/customer_detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/specialized/document_card.dart';
import '../../../data/models/customer.dart';
import '../../../app/app.dart';

class CustomerDetailView extends StatefulWidget {
  final Customer customer;

  const CustomerDetailView({super.key, required this.customer});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  @override
  void initState() {
    super.initState();
    // Load documents for this customer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentViewModel>().loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Customer Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              NavigationService.pushNamed(
                Routes.customerEdit,
                arguments: widget.customer,
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Customer'),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.errorColor),
                  title: Text('Delete Customer', 
                    style: TextStyle(color: AppColors.errorColor)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information Card
            _buildCustomerInfoCard(),
            
            const SizedBox(height: AppSpacing.md),
            
            // Documents Section
            _buildDocumentsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService.pushNamed(
            Routes.documentCreate,
            arguments: {'customer': widget.customer},
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryColor,
                  child: Text(
                    widget.customer.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer since ${_formatCreatedDate()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Contact Information
            if (widget.customer.email.isNotEmpty || widget.customer.phone.isNotEmpty) ...[
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: AppSpacing.sm),
              
              if (widget.customer.email.isNotEmpty)
                _buildInfoRow(
                  Icons.email,
                  'Email',
                  widget.customer.email,
                  onTap: () => _launchEmail(widget.customer.email),
                ),
              
              if (widget.customer.phone.isNotEmpty)
                _buildInfoRow(
                  Icons.phone,
                  'Phone',
                  widget.customer.phone,
                  onTap: () => _launchPhone(widget.customer.phone),
                ),
              
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Address Information
            if (widget.customer.fullAddress.isNotEmpty) ...[
              _buildSectionHeader('Address'),
              const SizedBox(height: AppSpacing.sm),
              
              _buildInfoRow(
                Icons.location_on,
                'Address',
                widget.customer.fullAddress,
                multiline: true,
              ),
              
              const SizedBox(height: AppSpacing.md),
            ],
            
            // Notes
            if (widget.customer.notes.isNotEmpty) ...[
              _buildSectionHeader('Notes'),
              const SizedBox(height: AppSpacing.sm),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.customer.notes,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Consumer<DocumentViewModel>(
      builder: (context, documentViewModel, child) {
        // Filter documents for this customer
        final customerDocuments = documentViewModel.documents
            .where((doc) => doc.customerId == widget.customer.id)
            .toList();

        return Card(
          margin: const EdgeInsets.all(AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Documents (${customerDocuments.length})',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        NavigationService.pushNamed(
                          Routes.documentCreate,
                          arguments: {'customer': widget.customer},
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Document'),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                if (documentViewModel.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (customerDocuments.isEmpty)
                  _buildEmptyDocuments()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customerDocuments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final document = customerDocuments[index];
                      return DocumentCard(
                        document: document,
                        customer: widget.customer,
                        onTap: () {
                          NavigationService.pushNamed(
                            Routes.documentView,
                            arguments: document,
                          );
                        },
                        onEdit: () {
                          NavigationService.pushNamed(
                            Routes.documentEdit,
                            arguments: document,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDocuments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No documents yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create your first document for this customer',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon, 
    String label, 
    String value, {
    bool multiline = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: onTap != null ? AppColors.primaryColor : AppColors.textSecondaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onTap != null ? AppColors.primaryColor : AppColors.textPrimaryColor,
                        decoration: onTap != null ? TextDecoration.underline : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCreatedDate() {
    final date = widget.customer.createdAt;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        NavigationService.pushNamed(
          Routes.customerEdit,
          arguments: widget.customer,
        );
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await NavigationUtils.showConfirmDialog(
      context,
      title: 'Delete Customer',
      message: 'Are you sure you want to delete ${widget.customer.name}? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CustomerViewModel>().deleteCustomer(widget.customer.id);
      if (success && mounted) {
        NavigationUtils.showSnackBar(
          context,
          'Customer deleted successfully',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      }
    }
  }

  void _launchEmail(String email) {
    // Implement email launch
    NavigationUtils.showSnackBar(
      context,
      'Email: $email',
      type: SnackBarType.info,
    );
  }

  void _launchPhone(String phone) {
    // Implement phone launch
    NavigationUtils.showSnackBar(
      context,
      'Phone: $phone',
      type: SnackBarType.info,
    );
  }
}