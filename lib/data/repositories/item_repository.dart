
// data/repositories/item_repository.dart - UPDATED WITH STORAGE
import '../../core/services/storage_service.dart';
import '../models/item.dart';

class ItemRepository {
  static List<Item> _items = [];
  static bool _isLoaded = false;

  /// Initialize repository with stored data
  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      _items = await StorageService.loadItems();
      _isLoaded = true;
    }
  }

  /// Generate unique ID
  String _generateId() {
    return 'item_${DateTime.now().millisecondsSinceEpoch}_${_items.length}';
  }

  Future<List<Item>> getItems() async {
    await _ensureLoaded();
    return List.from(_items);
  }

  Future<Item> createItem(Item item) async {
    await _ensureLoaded();
    
    final newItem = item.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
    );
    
    _items.insert(0, newItem);
    await StorageService.saveItems(_items);
    
    return newItem;
  }

  Future<Item> updateItem(Item item) async {
    await _ensureLoaded();
    
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      await StorageService.saveItems(_items);
    }
    
    return item;
  }

  Future<void> deleteItem(String itemId) async {
    await _ensureLoaded();
    
    _items.removeWhere((i) => i.id == itemId);
    await StorageService.saveItems(_items);
  }
}
