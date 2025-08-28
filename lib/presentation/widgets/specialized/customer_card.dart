
// presentation/widgets/specialized/customer_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      customer.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (customer.email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            customer.email,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              
              if (customer.phone.isNotEmpty || customer.fullAddress.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                if (customer.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        customer.phone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                if (customer.fullAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.fullAddress,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}