// data/repositories/dashboard_repository.dart - UPDATED WITH STORAGE
import '../../core/services/storage_service.dart';
import '../models/dashboard_stats.dart';
import '../models/document.dart';
import '../models/customer.dart';
import 'dart:math';

class DashboardRepository {
  static final Random _random = Random();

  Future<DashboardStats> getDashboardStats(DateTime period) async {
    // Load real data from storage
    final documents = await StorageService.loadDocuments();
    final customers = await StorageService.loadCustomers();
    
    // Calculate real stats
    final totalRevenue = documents
        .where((doc) => doc.status.toLowerCase() == 'paid')
        .fold<double>(0, (sum, doc) => sum + doc.total);
        
    final pendingAmount = documents
        .where((doc) => ['pending', 'sent', 'viewed'].contains(doc.status.toLowerCase()))
        .fold<double>(0, (sum, doc) => sum + doc.total);
        
    final overdueInvoices = documents
        .where((doc) => doc.dueDate != null && 
                       DateTime.now().isAfter(doc.dueDate!) && 
                       doc.status.toLowerCase() != 'paid')
        .length;
    
    // Generate revenue chart data based on real documents
    final revenueChart = _generateRevenueChart(documents);
    
    // Generate document type chart
    final documentTypeChart = _generateDocumentTypeChart(documents);
    
    // Generate status chart
    final statusChart = _generateStatusChart(documents);
    
    return DashboardStats(
      totalRevenue: totalRevenue,
      pendingAmount: pendingAmount,
      totalCustomers: customers.length,
      totalDocuments: documents.length,
      overdueInvoices: overdueInvoices,
      monthlyRevenue: _calculateMonthlyRevenue(documents),
      yearlyRevenue: _calculateYearlyRevenue(documents),
      revenueChart: revenueChart,
      documentTypeChart: documentTypeChart,
      statusChart: statusChart,
    );
  }

  List<RevenueData> _generateRevenueChart(List<Document> documents) {
    final chartData = <RevenueData>[];
    final now = DateTime.now();
    
    // Generate data for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      
      // Calculate revenue for this day from real documents
      final dayRevenue = documents
          .where((doc) => 
              doc.date.year == date.year &&
              doc.date.month == date.month &&
              doc.date.day == date.day &&
              doc.status.toLowerCase() == 'paid')
          .fold<double>(0, (sum, doc) => sum + doc.total);
      
      chartData.add(RevenueData(
        date: date,
        amount: dayRevenue,
        period: 'Day ${7 - i}',
      ));
    }
    
    return chartData;
  }

  List<DocumentTypeData> _generateDocumentTypeChart(List<Document> documents) {
    if (documents.isEmpty) return [];
    
    final typeCount = <String, int>{};
    
    for (final doc in documents) {
      typeCount[doc.type] = (typeCount[doc.type] ?? 0) + 1;
    }
    
    return typeCount.entries.map((entry) {
      final percentage = (entry.value / documents.length) * 100;
      return DocumentTypeData(
        type: entry.key,
        count: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  List<StatusData> _generateStatusChart(List<Document> documents) {
    if (documents.isEmpty) return [];
    
    final statusCount = <String, int>{};
    
    for (final doc in documents) {
      statusCount[doc.status] = (statusCount[doc.status] ?? 0) + 1;
    }
    
    return statusCount.entries.map((entry) {
      final percentage = (entry.value / documents.length) * 100;
      return StatusData(
        status: entry.key,
        count: entry.value,
        percentage: percentage,
      );
    }).toList();
  }

  double _calculateMonthlyRevenue(List<Document> documents) {
    final now = DateTime.now();
    return documents
        .where((doc) => 
            doc.date.year == now.year &&
            doc.date.month == now.month &&
            doc.status.toLowerCase() == 'paid')
        .fold<double>(0, (sum, doc) => sum + doc.total);
  }

  double _calculateYearlyRevenue(List<Document> documents) {
    final now = DateTime.now();
    return documents
        .where((doc) => 
            doc.date.year == now.year &&
            doc.status.toLowerCase() == 'paid')
        .fold<double>(0, (sum, doc) => sum + doc.total);
  }
}