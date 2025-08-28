
// lib/data/repositories/customer_repository.dart - FINAL FIXED VERSION
import '../../core/services/api_service.dart';
import '../models/customer.dart';

class CustomerRepository {
  final MockApiService _apiService = MockApiService();

  Future<List<Customer>> getCustomers() async {
    return await _apiService.getCustomers();
  }

  Future<Customer> createCustomer(Customer customer) async {
    return await _apiService.createCustomer(customer);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    return await _apiService.updateCustomer(customer);
  }

  Future<void> deleteCustomer(String customerId) async {
    return await _apiService.deleteCustomer(customerId);
  }
}
