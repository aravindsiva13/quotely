import '../../../data/models/document.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/document_repository.dart';
import 'base_viewmodel.dart';

class DocumentViewModel extends BaseViewModel {
  final DocumentRepository _documentRepository = DocumentRepository();
  
  List<Document> _documents = [];
  List<Customer> _customers = [];
  DocumentFilter _filter = DocumentFilter();

  // Getters - Single source of truth
  List<Document> get documents => _documents;
  List<Customer> get customers => _customers;
  DocumentFilter get filter => _filter;
  
  List<Document> get filteredDocuments => _applyFilter(_documents);

  DocumentViewModel() {
    loadDocuments();
  }

  // Load all documents
  Future<void> loadDocuments() async {
    try {
      setLoading(true);
      clearError();
      
      final result = await _documentRepository.getDocuments();
      _documents = result;
      
      // Also load customers for document creation
      _customers = await _documentRepository.getCustomers();
      
      setState();
    } catch (e) {
      setError('Failed to load documents: $e');
    } finally {
      setLoading(false);
    }
  }

  // Create new document
  Future<bool> createDocument(Document document) async {
    try {
      setLoading(true);
      clearError();
      
      final createdDocument = await _documentRepository.createDocument(document);
      _documents.insert(0, createdDocument);
      setState();
      return true;
    } catch (e) {
      setError('Failed to create document: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update existing document
  Future<bool> updateDocument(Document document) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedDocument = await _documentRepository.updateDocument(document);
      final index = _documents.indexWhere((d) => d.id == document.id);
      if (index != -1) {
        _documents[index] = updatedDocument;
        setState();
      }
      return true;
    } catch (e) {
      setError('Failed to update document: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Delete document
  Future<bool> deleteDocument(String documentId) async {
    try {
      setLoading(true);
      clearError();
      
      await _documentRepository.deleteDocument(documentId);
      _documents.removeWhere((d) => d.id == documentId);
      setState();
      return true;
    } catch (e) {
      setError('Failed to delete document: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update document status
  Future<bool> updateDocumentStatus(String documentId, String status) async {
    try {
      setLoading(true);
      clearError();
      
      await _documentRepository.updateDocumentStatus(documentId, status);
      final index = _documents.indexWhere((d) => d.id == documentId);
      if (index != -1) {
        _documents[index] = _documents[index].copyWith(status: status);
        setState();
      }
      return true;
    } catch (e) {
      setError('Failed to update document status: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Filter documents
  void updateFilter(DocumentFilter newFilter) {
    _filter = newFilter;
    setState();
  }

  void clearFilter() {
    _filter = DocumentFilter();
    setState();
  }

  // Search documents
  void searchDocuments(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    setState();
  }

  // Get document by ID
  Document? getDocumentById(String id) {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get customer by ID
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper to apply filters
  List<Document> _applyFilter(List<Document> documents) {
    var filtered = documents;

    // Apply search query
    if (_filter.searchQuery.isNotEmpty) {
      filtered = filtered.where((doc) {
        final customer = getCustomerById(doc.customerId);
        return doc.number.toLowerCase().contains(_filter.searchQuery.toLowerCase()) ||
               doc.type.toLowerCase().contains(_filter.searchQuery.toLowerCase()) ||
               (customer?.name.toLowerCase().contains(_filter.searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply status filter
    if (_filter.status != null) {
      filtered = filtered.where((doc) => doc.status == _filter.status).toList();
    }

    // Apply type filter
    if (_filter.type != null) {
      filtered = filtered.where((doc) => doc.type == _filter.type).toList();
    }

    // Apply date range filter
    if (_filter.startDate != null) {
      filtered = filtered.where((doc) => doc.date.isAfter(_filter.startDate!)).toList();
    }
    if (_filter.endDate != null) {
      filtered = filtered.where((doc) => doc.date.isBefore(_filter.endDate!)).toList();
    }

    // Apply sorting
    switch (_filter.sortBy) {
      case 'date':
        filtered.sort((a, b) => _filter.sortDescending ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
        break;
      case 'total':
        filtered.sort((a, b) => _filter.sortDescending ? b.total.compareTo(a.total) : a.total.compareTo(b.total));
        break;
      case 'customer':
        filtered.sort((a, b) {
          final customerA = getCustomerById(a.customerId)?.name ?? '';
          final customerB = getCustomerById(b.customerId)?.name ?? '';
          return _filter.sortDescending ? customerB.compareTo(customerA) : customerA.compareTo(customerB);
        });
        break;
      default:
        filtered.sort((a, b) => _filter.sortDescending ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));
    }

    return filtered;
  }
}

// Document Filter Model
class DocumentFilter {
  final String searchQuery;
  final String? status;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy;
  final bool sortDescending;

  DocumentFilter({
    this.searchQuery = '',
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.sortBy = 'date',
    this.sortDescending = true,
  });

  DocumentFilter copyWith({
    String? searchQuery,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool? sortDescending,
  }) {
    return DocumentFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}