
// data/repositories/document_repository.dart - UPDATED WITH STORAGE
import '../../core/services/storage_service.dart';
import '../models/document.dart';
import '../models/customer.dart';

class DocumentRepository {
  static List<Document> _documents = [];
  static List<Customer> _customers = [];
  static bool _isLoaded = false;

  /// Initialize repository with stored data
  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      _documents = await StorageService.loadDocuments();
      _customers = await StorageService.loadCustomers();
      _isLoaded = true;
    }
  }

  /// Generate unique ID
  String _generateId() {
    return 'doc_${DateTime.now().millisecondsSinceEpoch}_${_documents.length}';
  }

  // Document CRUD operations
  Future<List<Document>> getDocuments() async {
    await _ensureLoaded();
    return List.from(_documents);
  }

  Future<Document> createDocument(Document document) async {
    await _ensureLoaded();
    
    final newDocument = document.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _documents.insert(0, newDocument);
    await StorageService.saveDocuments(_documents);
    
    return newDocument;
  }

  Future<Document> updateDocument(Document document) async {
    await _ensureLoaded();
    
    final updatedDocument = document.copyWith(
      updatedAt: DateTime.now(),
    );
    
    final index = _documents.indexWhere((d) => d.id == document.id);
    if (index != -1) {
      _documents[index] = updatedDocument;
      await StorageService.saveDocuments(_documents);
    }
    
    return updatedDocument;
  }

  Future<void> deleteDocument(String documentId) async {
    await _ensureLoaded();
    
    _documents.removeWhere((d) => d.id == documentId);
    await StorageService.saveDocuments(_documents);
  }

  Future<void> updateDocumentStatus(String documentId, String status) async {
    await _ensureLoaded();
    
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index != -1) {
      _documents[index] = _documents[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveDocuments(_documents);
    }
  }

  // Customer operations (needed for document creation)
  Future<List<Customer>> getCustomers() async {
    await _ensureLoaded();
    return List.from(_customers);
  }

  Future<Customer?> getCustomerById(String customerId) async {
    await _ensureLoaded();
    try {
      return _customers.firstWhere((customer) => customer.id == customerId);
    } catch (e) {
      return null;
    }
  }
}
