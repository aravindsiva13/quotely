
// data/models/dashboard_stats.dart
class DashboardStats {
  final double totalRevenue;
  final double pendingAmount;
  final int totalCustomers;
  final int totalDocuments;
  final int overdueInvoices;
  final double monthlyRevenue;
  final double yearlyRevenue;
  final List<RevenueData> revenueChart;
  final List<DocumentTypeData> documentTypeChart;
  final List<StatusData> statusChart;

  DashboardStats({
    required this.totalRevenue,
    required this.pendingAmount,
    required this.totalCustomers,
    required this.totalDocuments,
    required this.overdueInvoices,
    required this.monthlyRevenue,
    required this.yearlyRevenue,
    required this.revenueChart,
    required this.documentTypeChart,
    required this.statusChart,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      pendingAmount: (json['pending_amount'] ?? 0.0).toDouble(),
      totalCustomers: json['total_customers'] ?? 0,
      totalDocuments: json['total_documents'] ?? 0,
      overdueInvoices: json['overdue_invoices'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] ?? 0.0).toDouble(),
      yearlyRevenue: (json['yearly_revenue'] ?? 0.0).toDouble(),
      revenueChart: json['revenue_chart'] != null
          ? (json['revenue_chart'] as List)
              .map((item) => RevenueData.fromJson(item))
              .toList()
          : [],
      documentTypeChart: json['document_type_chart'] != null
          ? (json['document_type_chart'] as List)
              .map((item) => DocumentTypeData.fromJson(item))
              .toList()
          : [],
      statusChart: json['status_chart'] != null
          ? (json['status_chart'] as List)
              .map((item) => StatusData.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'pending_amount': pendingAmount,
      'total_customers': totalCustomers,
      'total_documents': totalDocuments,
      'overdue_invoices': overdueInvoices,
      'monthly_revenue': monthlyRevenue,
      'yearly_revenue': yearlyRevenue,
      'revenue_chart': revenueChart.map((item) => item.toJson()).toList(),
      'document_type_chart': documentTypeChart.map((item) => item.toJson()).toList(),
      'status_chart': statusChart.map((item) => item.toJson()).toList(),
    };
  }
}

class RevenueData {
  final DateTime date;
  final double amount;
  final String period;

  RevenueData({
    required this.date,
    required this.amount,
    required this.period,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      period: json['period'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'period': period,
    };
  }
}

class DocumentTypeData {
  final String type;
  final int count;
  final double percentage;

  DocumentTypeData({
    required this.type,
    required this.count,
    required this.percentage,
  });

  factory DocumentTypeData.fromJson(Map<String, dynamic> json) {
    return DocumentTypeData(
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
      'percentage': percentage,
    };
  }
}

class StatusData {
  final String status;
  final int count;
  final double percentage;

  StatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });

  factory StatusData.fromJson(Map<String, dynamic> json) {
    return StatusData(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'percentage': percentage,
    };
  }
}