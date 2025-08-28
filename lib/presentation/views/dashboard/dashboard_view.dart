
// presentation/views/dashboard/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/specialized/dashboard_stats_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Load data when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Dashboard',
        showBackButton: false,
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {
          if (dashboardViewModel.isLoading && !dashboardViewModel.hasStats) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardViewModel.hasError) {
            return _buildErrorState(dashboardViewModel.error!);
          }

          return RefreshIndicator(
            onRefresh: dashboardViewModel.refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _buildQuickStats(dashboardViewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Revenue Chart
                  _buildRevenueChart(dashboardViewModel),
                  
                  const SizedBox(height: 24),
                  
                  // Document Types Chart
                  _buildDocumentTypesChart(dashboardViewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(DashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            DashboardStatsCard(
              title: 'Total Revenue',
              value: CurrencyUtils.formatAmount(viewModel.totalRevenue),
              icon: Icons.attach_money,
              color: AppColors.primaryColor,
              trend: viewModel.getRevenueTrend(),
            ),
            DashboardStatsCard(
              title: 'Pending Amount',
              value: CurrencyUtils.formatAmount(viewModel.pendingAmount),
              icon: Icons.pending_actions,
              color: AppColors.warningColor,
            ),
            DashboardStatsCard(
              title: 'Total Customers',
              value: '${viewModel.totalCustomers}',
              icon: Icons.people,
              color: AppColors.infoColor,
            ),
            DashboardStatsCard(
              title: 'Total Documents',
              value: '${viewModel.totalDocuments}',
              icon: Icons.description,
              color: AppColors.successColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueChart(DashboardViewModel viewModel) {
    if (!viewModel.hasStats || viewModel.stats!.revenueChart.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.stats!.revenueChart
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value.amount,
                              ))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypesChart(DashboardViewModel viewModel) {
    if (!viewModel.hasStats || viewModel.stats!.documentTypeChart.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Types',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 16),
            ...viewModel.stats!.documentTypeChart.map(
              (data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.type,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    Text(
                      '${data.count} (${data.percentage.toStringAsFixed(1)}%)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardViewModel>().loadDashboardStats();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
