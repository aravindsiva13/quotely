
// presentation/views/documents/document_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/document_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/specialized/document_card.dart';
import '../../../app/app.dart';

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load documents when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentViewModel>().loadDocuments();
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
      appBar: CustomAppBar(
        title: 'Documents',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<DocumentViewModel>(
        builder: (context, documentViewModel, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              documentViewModel.searchDocuments('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: documentViewModel.searchDocuments,
                ),
              ),
              
              // Documents List
              Expanded(
                child: _buildDocumentsList(documentViewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService.pushNamed(Routes.documentCreate);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDocumentsList(DocumentViewModel viewModel) {
    if (viewModel.isLoading && viewModel.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return _buildErrorState(viewModel.error!);
    }

    final filteredDocuments = viewModel.filteredDocuments;

    if (filteredDocuments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: filteredDocuments.length,
        itemBuilder: (context, index) {
          final document = filteredDocuments[index];
          final customer = viewModel.getCustomerById(document.customerId);
          
          return DocumentCard(
            document: document,
            customer: customer,
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
            onDelete: () => _confirmDelete(document.id),
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
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first document to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              NavigationService.pushNamed(Routes.documentCreate);
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Document'),
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
          const SizedBox(height: 16),
          Text(
            'Error loading documents',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DocumentViewModel>().loadDocuments();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Documents'),
        content: const Text('Filter options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
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
      final success = await context.read<DocumentViewModel>().deleteDocument(documentId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}