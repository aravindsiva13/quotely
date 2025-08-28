// lib/data/repositories/document_repository.dart - FINAL FIXED VERSION
import '../../core/services/api_service.dart';
import '../models/document.dart';
import '../models/customer.dart';

class DocumentRepository {
  final MockApiService _apiService = MockApiService();

  // Document CRUD operations
  Future<List<Document>> getDocuments() async {
    return await _apiService.getDocuments();
  }

  Future<Document> createDocument(Document document) async {
    return await _apiService.createDocument(document);
  }

  Future<Document> updateDocument(Document document) async {
    return await _apiService.updateDocument(document);
  }

  Future<void> deleteDocument(String documentId) async {
    return await _apiService.deleteDocument(documentId);
  }

  Future<void> updateDocumentStatus(String documentId, String status) async {
    return await _apiService.updateDocumentStatus(documentId, status);
  }

  // Customer operations (needed for document creation)
  Future<List<Customer>> getCustomers() async {
    return await _apiService.getCustomers();
  }

  Future<Customer?> getCustomerById(String customerId) async {
    final customers = await getCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == customerId);
    } catch (e) {
      return null;
    }
  }
}