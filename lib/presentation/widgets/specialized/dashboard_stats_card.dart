
// presentation/widgets/specialized/dashboard_stats_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (trend != null) _buildTrendIndicator(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    if (trend == null || trend == 0) return const SizedBox.shrink();
    
    final isPositive = trend! > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: isPositive ? AppColors.successColor : AppColors.errorColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${trend!.abs().toStringAsFixed(1)}%',
          style: AppTextStyles.caption.copyWith(
            color: isPositive ? AppColors.successColor : AppColors.errorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
