// lib/data/repositories/auth_repository.dart - FINAL FIXED VERSION
import '../../core/services/api_service.dart';
import '../models/user.dart';

class AuthRepository {
  final MockApiService _apiService = MockApiService();

  Future<AuthResponse> login(String email, String password) async {
    return await _apiService.login(email, password);
  }

  Future<AuthResponse> register(UserRegistration registration) async {
    return await _apiService.register(registration);
  }

  Future<void> logout() async {
    return await _apiService.logout();
  }

  Future<User?> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  Future<User> updateProfile(User user) async {
    return await _apiService.updateUser(user);
  }
}
