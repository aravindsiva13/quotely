import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import 'base_viewmodel.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  
  User? _currentUser;
  bool _isInitializing = true;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitializing => _isInitializing;

  AuthViewModel() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      setLoading(true);
      _currentUser = await _authRepository.getCurrentUser();
      _isInitializing = false;
    } catch (e) {
      setError('Failed to initialize auth: $e');
      _isInitializing = false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      clearError();
      
      final response = await _authRepository.login(email, password);
      
      if (response.success && response.user != null) {
        _currentUser = response.user;
        setState();
        return true;
      } else {
        setError(response.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      setError('Login error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register(UserRegistration registration) async {
    try {
      setLoading(true);
      clearError();
      
      final response = await _authRepository.register(registration);
      
      if (response.success && response.user != null) {
        _currentUser = response.user;
        setState();
        return true;
      } else {
        setError(response.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      setError('Registration error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      setLoading(true);
      await _authRepository.logout();
      _currentUser = null;
      setState();
    } catch (e) {
      setError('Logout error: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProfile(User user) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedUser = await _authRepository.updateProfile(user);
      _currentUser = updatedUser;
      setState();
      return true;
    } catch (e) {
      setError('Profile update error: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
