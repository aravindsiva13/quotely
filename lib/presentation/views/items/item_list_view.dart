
// presentation/views/items/item_list_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/item_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../app/app.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({super.key});

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemViewModel>().loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Items',
        showBackButton: false,
      ),
      body: Consumer<ItemViewModel>(
        builder: (context, itemViewModel, child) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: itemViewModel.searchItems,
                ),
              ),
              
              // Items List
              Expanded(
                child: _buildItemsList(itemViewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService.pushNamed(Routes.itemCreate);
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildItemsList(ItemViewModel viewModel) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredItems = viewModel.filteredItems;

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text('No items found'),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.description),
              trailing: Text('\${item.price.toStringAsFixed(2)}'),
              onTap: () {
                NavigationService.pushNamed(
                  Routes.itemEdit,
                  arguments: item,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
