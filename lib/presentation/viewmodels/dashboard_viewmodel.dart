// presentation/viewmodels/dashboard_viewmodel.dart
import '../../../data/models/dashboard_stats.dart';
import '../../../data/repositories/dashboard_repository.dart';
import 'base_viewmodel.dart';

class DashboardViewModel extends BaseViewModel {
  final DashboardRepository _dashboardRepository = DashboardRepository();
  
  DashboardStats? _stats;
  DateTime _selectedPeriod = DateTime.now();

  // Getters - Single source of truth
  DashboardStats? get stats => _stats;
  DateTime get selectedPeriod => _selectedPeriod;
  
  bool get hasStats => _stats != null;
  double get totalRevenue => _stats?.totalRevenue ?? 0.0;
  double get pendingAmount => _stats?.pendingAmount ?? 0.0;
  int get totalCustomers => _stats?.totalCustomers ?? 0;
  int get totalDocuments => _stats?.totalDocuments ?? 0;
  int get overdueInvoices => _stats?.overdueInvoices ?? 0;

  DashboardViewModel() {
    loadDashboardStats();
  }

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      setLoading(true);
      clearError();
      
      _stats = await _dashboardRepository.getDashboardStats(_selectedPeriod);
      setState();
    } catch (e) {
      setError('Failed to load dashboard stats: $e');
    } finally {
      setLoading(false);
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardStats();
  }

  // Change time period filter
  Future<void> changePeriod(DateTime period) async {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      await loadDashboardStats();
    }
  }

  // Get revenue trend (percentage change)
  double getRevenueTrend() {
    if (_stats == null || _stats!.revenueChart.length < 2) return 0.0;
    
    final current = _stats!.revenueChart.last.amount;
    final previous = _stats!.revenueChart[_stats!.revenueChart.length - 2].amount;
    
    if (previous == 0) return 0.0;
    return ((current - previous) / previous) * 100;
  }

  // Get collection efficiency (percentage of pending vs total)
  double getCollectionEfficiency() {
    if (_stats == null || _stats!.totalRevenue == 0) return 0.0;
    
    final collected = _stats!.totalRevenue - _stats!.pendingAmount;
    return (collected / _stats!.totalRevenue) * 100;
  }
}

