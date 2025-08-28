
// lib/data/repositories/item_repository.dart - FINAL FIXED VERSION
import '../../core/services/api_service.dart';
import '../models/item.dart';

class ItemRepository {
  final MockApiService _apiService = MockApiService();

  Future<List<Item>> getItems() async {
    return await _apiService.getItems();
  }

  Future<Item> createItem(Item item) async {
    return await _apiService.createItem(item);
  }

  Future<Item> updateItem(Item item) async {
    return await _apiService.updateItem(item);
  }

  Future<void> deleteItem(String itemId) async {
    return await _apiService.deleteItem(itemId);
  }
}

