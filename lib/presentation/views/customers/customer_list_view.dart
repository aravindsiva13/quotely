
// presentation/views/customers/customer_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/specialized/customer_card.dart';
import '../../../app/app.dart';

class CustomerListView extends StatefulWidget {
  const CustomerListView({super.key});

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Customers',
        showBackButton: false,
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, customerViewModel, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              customerViewModel.clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: customerViewModel.searchCustomers,
                ),
              ),
              
              // Customers List
              Expanded(
                child: _buildCustomersList(customerViewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService.pushNamed(Routes.customerCreate);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomersList(CustomerViewModel viewModel) {
    if (viewModel.isLoading && viewModel.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return _buildErrorState(viewModel.error!);
    }

    final filteredCustomers = viewModel.filteredCustomers;

    if (filteredCustomers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadCustomers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = filteredCustomers[index];
          
          return CustomerCard(
            customer: customer,
            onTap: () {
              NavigationService.pushNamed(
                Routes.customerDetail,
                arguments: customer,
              );
            },
            onEdit: () {
              NavigationService.pushNamed(
                Routes.customerEdit,
                arguments: customer,
              );
            },
            onDelete: () => _confirmDelete(customer.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No customers found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first customer to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error loading customers',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              context.read<CustomerViewModel>().loadCustomers();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String customerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<CustomerViewModel>().deleteCustomer(customerId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
