// presentation/viewmodels/item_viewmodel.dart
import '../../../data/models/item.dart';
import '../../../data/repositories/item_repository.dart';
import 'base_viewmodel.dart';

class ItemViewModel extends BaseViewModel {
  final ItemRepository _itemRepository = ItemRepository();
  
  List<Item> _items = [];
  String _searchQuery = '';
  String? _categoryFilter;

  // Getters - Single source of truth
  List<Item> get items => _items;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  
  List<Item> get filteredItems => _applyFilters(_items);
  List<String> get categories => _getUniqueCategories();

  ItemViewModel() {
    loadItems();
  }

  // Load all items
  Future<void> loadItems() async {
    try {
      setLoading(true);
      clearError();
      
      final result = await _itemRepository.getItems();
      _items = result;
      setState();
    } catch (e) {
      setError('Failed to load items: $e');
    } finally {
      setLoading(false);
    }
  }

  // Create new item
  Future<bool> createItem(Item item) async {
    try {
      setLoading(true);
      clearError();
      
      final createdItem = await _itemRepository.createItem(item);
      _items.insert(0, createdItem);
      setState();
      return true;
    } catch (e) {
      setError('Failed to create item: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update existing item
  Future<bool> updateItem(Item item) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedItem = await _itemRepository.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = updatedItem;
        setState();
      }
      return true;
    } catch (e) {
      setError('Failed to update item: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Delete item
  Future<bool> deleteItem(String itemId) async {
    try {
      setLoading(true);
      clearError();
      
      await _itemRepository.deleteItem(itemId);
      _items.removeWhere((i) => i.id == itemId);
      setState();
      return true;
    } catch (e) {
      setError('Failed to delete item: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Search items
  void searchItems(String query) {
    _searchQuery = query;
    setState();
  }

  void clearSearch() {
    _searchQuery = '';
    setState();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _categoryFilter = category;
    setState();
  }

  void clearCategoryFilter() {
    _categoryFilter = null;
    setState();
  }

  // Get item by ID
  Item? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper to apply filters
  List<Item> _applyFilters(List<Item> items) {
    var filtered = items;

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(lowercaseQuery) ||
               item.description.toLowerCase().contains(lowercaseQuery) ||
               (item.category?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((item) => item.category == _categoryFilter).toList();
    }

    return filtered;
  }

  // Get unique categories
  List<String> _getUniqueCategories() {
    final categories = <String>{};
    for (final item in _items) {
      if (item.category != null && item.category!.isNotEmpty) {
        categories.add(item.category!);
      }
    }
    return categories.toList()..sort();
  }
}
