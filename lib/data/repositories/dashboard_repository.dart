// lib/data/repositories/dashboard_repository.dart - FINAL FIXED VERSION
import '../../core/services/api_service.dart';
import '../models/dashboard_stats.dart';

class DashboardRepository {
  final MockApiService _apiService = MockApiService();

  Future<DashboardStats> getDashboardStats(DateTime period) async {
    return await _apiService.getDashboardStats(period);
  }
}