
// presentation/views/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/custom_app_bar.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: false,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Profile Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            user?.businessName.substring(0, 1).toUpperCase() ?? 'U',
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user?.businessName ?? 'Business Name',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Settings Options
                Card(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.business,
                        title: 'Business Information',
                        subtitle: 'Update your business details',
                        onTap: () {
                          // TODO: Navigate to business info screen
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.palette,
                        title: 'Templates & Themes',
                        subtitle: 'Customize document templates',
                        onTap: () {
                          // TODO: Navigate to templates screen
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.backup,
                        title: 'Backup & Restore',
                        subtitle: 'Backup your data',
                        onTap: () {
                          // TODO: Navigate to backup screen
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorColor,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthViewModel>().logout();
    }
  }
}
