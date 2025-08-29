// presentation/viewmodels/customer_viewmodel.dart
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import 'base_viewmodel.dart';

class CustomerViewModel extends BaseViewModel {
  final CustomerRepository _customerRepository = CustomerRepository();
  
  List<Customer> _customers = [];
  String _searchQuery = '';

  // Getters - Single source of truth
  List<Customer> get customers => _customers;
  String get searchQuery => _searchQuery;
  
  List<Customer> get filteredCustomers => _applySearch(_customers);

  CustomerViewModel() {
    loadCustomers();
  }

  // Load all customers
  Future<void> loadCustomers() async {
    try {
      setLoading(true);
      clearError();
      
      final result = await _customerRepository.getCustomers();
      _customers = result;
      setState();
    } catch (e) {
      setError('Failed to load customers: $e');
    } finally {
      setLoading(false);
    }
  }

  // Create new customer
  Future<bool> createCustomer(Customer customer) async {
    try {
      setLoading(true);
      clearError();
      
      final createdCustomer = await _customerRepository.createCustomer(customer);
      _customers.insert(0, createdCustomer);
      setState();
      return true;
    } catch (e) {
      setError('Failed to create customer: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update existing customer
  Future<bool> updateCustomer(Customer customer) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedCustomer = await _customerRepository.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        setState();
      }
      return true;
    } catch (e) {
      setError('Failed to update customer: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      setLoading(true);
      clearError();
      
      await _customerRepository.deleteCustomer(customerId);
      _customers.removeWhere((c) => c.id == customerId);
      setState();
      return true;
    } catch (e) {
      setError('Failed to delete customer: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Search customers
  void searchCustomers(String query) {
    _searchQuery = query;
    setState();
  }

  void clearSearch() {
    _searchQuery = '';
    setState();
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper to apply search
  List<Customer> _applySearch(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    
    final lowercaseQuery = _searchQuery.toLowerCase();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(lowercaseQuery) ||
             customer.email.toLowerCase().contains(lowercaseQuery) ||
             customer.phone.toLowerCase().contains(lowercaseQuery) ||
             customer.address.toLowerCase().contains(lowercaseQuery) ||
             customer.city.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

