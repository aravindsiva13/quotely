// data/repositories/auth_repository.dart - UPDATED WITH STORAGE
import '../../core/services/storage_service.dart';
import '../models/user.dart';

class AuthRepository {
  static User? _currentUser;
  static bool _isLoaded = false;

  /// Initialize repository with stored data
  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      _currentUser = await StorageService.loadUser();
      _isLoaded = true;
    }
  }

  /// Generate unique ID
  String _generateId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<AuthResponse> login(String email, String password) async {
    await _ensureLoaded();
    
    // Check if user exists and credentials match
    if (_currentUser?.email == email && password == 'demo123') {
      return AuthResponse(
        success: true,
        user: _currentUser,
        token: 'token_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Login successful',
      );
    }
    
    // Demo login for testing
    if (email == 'demo@test.com' && password == 'demo123') {
      final demoUser = User(
        id: _generateId(),
        email: email,
        businessName: 'Demo Business Inc',
        settings: UserSettings(
          currency: 'USD',
          currencySymbol: '\$',
          defaultTaxRate: 18.0,
          templateTheme: 'professional',
          businessInfo: BusinessInfo(
            name: 'Demo Business Inc',
            address: '123 Business Street',
            city: 'New York',
            state: 'NY',
            country: 'USA',
            zipCode: '10001',
            phone: '+1 (555) 123-4567',
            email: email,
            website: 'www.demobusiness.com',
            taxId: 'TX123456789',
            registrationNumber: 'REG987654321',
          ),
        ),
        createdAt: DateTime.now(),
      );
      
      _currentUser = demoUser;
      await StorageService.saveUser(demoUser);
      
      return AuthResponse(
        success: true,
        user: demoUser,
        token: 'token_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Login successful',
      );
    }
    
    return AuthResponse(
      success: false,
      error: 'Invalid email or password',
    );
  }

  Future<AuthResponse> register(UserRegistration registration) async {
    await _ensureLoaded();
    
    // Check if user already exists
    if (_currentUser?.email == registration.email) {
      return AuthResponse(
        success: false,
        error: 'User with this email already exists',
      );
    }
    
    // Create new user
    final newUser = User(
      id: _generateId(),
      email: registration.email,
      businessName: registration.businessName,
      settings: UserSettings(
        currency: 'USD',
        currencySymbol: '\$',
        defaultTaxRate: 18.0,
        templateTheme: 'professional',
        businessInfo: BusinessInfo(
          name: registration.businessName,
          email: registration.email,
          phone: registration.phone,
          country: registration.country,
        ),
      ),
      createdAt: DateTime.now(),
    );
    
    _currentUser = newUser;
    await StorageService.saveUser(newUser);
    
    return AuthResponse(
      success: true,
      user: newUser,
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
      message: 'Registration successful',
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    await StorageService.deleteUser();
  }

  Future<User?> getCurrentUser() async {
    await _ensureLoaded();
    return _currentUser;
  }

  Future<User> updateProfile(User user) async {
    await _ensureLoaded();
    
    _currentUser = user;
    await StorageService.saveUser(user);
    
    return user;
  }
}
