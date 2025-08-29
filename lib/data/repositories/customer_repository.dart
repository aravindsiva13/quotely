// data/repositories/customer_repository.dart - UPDATED WITH STORAGE
import '../../core/services/storage_service.dart';
import '../models/customer.dart';

class CustomerRepository {
  static List<Customer> _customers = [];
  static bool _isLoaded = false;

  /// Initialize repository with stored data
  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      _customers = await StorageService.loadCustomers();
      _isLoaded = true;
    }
  }

  /// Generate unique ID
  String _generateId() {
    return 'customer_${DateTime.now().millisecondsSinceEpoch}_${_customers.length}';
  }

  Future<List<Customer>> getCustomers() async {
    await _ensureLoaded();
    return List.from(_customers);
  }

  Future<Customer> createCustomer(Customer customer) async {
    await _ensureLoaded();
    
    final newCustomer = customer.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
    );
    
    _customers.insert(0, newCustomer);
    await StorageService.saveCustomers(_customers);
    
    return newCustomer;
  }

  Future<Customer> updateCustomer(Customer customer) async {
    await _ensureLoaded();
    
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      await StorageService.saveCustomers(_customers);
    }
    
    return customer;
  }

  Future<void> deleteCustomer(String customerId) async {
    await _ensureLoaded();
    
    _customers.removeWhere((c) => c.id == customerId);
    await StorageService.saveCustomers(_customers);
  }
}
