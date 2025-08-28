// presentation/viewmodels/base_viewmodel.dart
import 'package:flutter/foundation.dart';

/// Base ViewModel class that provides common functionality
/// All ViewModels should extend this class
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Protected methods for subclasses
  @protected
  void setLoading(bool loading) {
    if (_isDisposed) return;
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @protected
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  @protected
  void clearError() {
    if (_isDisposed) return;
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @protected
  void setState() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}