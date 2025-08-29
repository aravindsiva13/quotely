
// presentation/widgets/specialized/document_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/document.dart';
import '../../../data/models/customer.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final Customer? customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.number,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (customer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            customer!.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Amount and Date Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      CurrencyUtils.formatAmount(
                        document.total, 
                        document.currencySymbol,
                      ),
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    AppDateUtils.formatDate(document.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              
              if (document.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppDateUtils.isOverdue(document.dueDate)
                          ? AppColors.errorColor
                          : AppColors.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due ${AppDateUtils.formatDate(document.dueDate!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppDateUtils.isOverdue(document.dueDate)
                            ? AppColors.errorColor
                            : AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Actions Row
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                        ),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.errorColor,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor;
    switch (document.status.toLowerCase()) {
      case 'paid':
        statusColor = AppColors.successColor;
        break;
      case 'overdue':
        statusColor = AppColors.errorColor;
        break;
      case 'pending':
      case 'sent':
        statusColor = AppColors.warningColor;
        break;
      default:
        statusColor = AppColors.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        document.status,
        style: AppTextStyles.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}