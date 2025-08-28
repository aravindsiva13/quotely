// presentation/views/settings/business_info_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/user.dart';

class BusinessInfoView extends StatefulWidget {
  const BusinessInfoView({super.key});

  @override
  State<BusinessInfoView> createState() => _BusinessInfoViewState();
}

class _BusinessInfoViewState extends State<BusinessInfoView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for Business Info
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _taxIdController;
  late TextEditingController _registrationNumberController;
  
  // Controllers for Currency & Settings
  late TextEditingController _currencyController;
  late TextEditingController _currencySymbolController;
  late TextEditingController _defaultTaxRateController;
  
  String _selectedTheme = 'professional';
  bool _darkMode = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authViewModel = context.read<AuthViewModel>();
    final user = authViewModel.currentUser;
    final businessInfo = user?.settings.businessInfo;
    final settings = user?.settings;
    
    // Business Info Controllers
    _businessNameController = TextEditingController(text: businessInfo?.name ?? '');
    _addressController = TextEditingController(text: businessInfo?.address ?? '');
    _cityController = TextEditingController(text: businessInfo?.city ?? '');
    _stateController = TextEditingController(text: businessInfo?.state ?? '');
    _countryController = TextEditingController(text: businessInfo?.country ?? '');
    _zipCodeController = TextEditingController(text: businessInfo?.zipCode ?? '');
    _phoneController = TextEditingController(text: businessInfo?.phone ?? '');
    _emailController = TextEditingController(text: businessInfo?.email ?? '');
    _websiteController = TextEditingController(text: businessInfo?.website ?? '');
    _taxIdController = TextEditingController(text: businessInfo?.taxId ?? '');
    _registrationNumberController = TextEditingController(text: businessInfo?.registrationNumber ?? '');
    
    // Settings Controllers
    _currencyController = TextEditingController(text: settings?.currency ?? 'USD');
    _currencySymbolController = TextEditingController(text: settings?.currencySymbol ?? '\$');
    _defaultTaxRateController = TextEditingController(text: settings?.defaultTaxRate.toString() ?? '18.0');
    
    // Settings Values
    _selectedTheme = settings?.templateTheme ?? 'professional';
    _darkMode = settings?.darkMode ?? false;
    _selectedLanguage = settings?.language ?? 'en';
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    _currencyController.dispose();
    _currencySymbolController.dispose();
    _defaultTaxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Business Information',
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Details Section
                  _buildBusinessDetailsSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Address Section
                  _buildAddressSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Contact Information Section
                  _buildContactSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Business Settings Section
                  _buildBusinessSettingsSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // App Preferences Section
                  _buildAppPreferencesSection(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Save Button
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: authViewModel.isLoading ? null : _handleSave,
                    isLoading: authViewModel.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessDetailsSection() {
    return _buildSection(
      title: 'Business Details',
      children: [
        CustomTextField(
          label: 'Business Name *',
          controller: _businessNameController,
          validator: (value) => ValidationUtils.validateRequired(value, 'Business name'),
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Tax ID',
                controller: _taxIdController,
                hint: 'e.g., 123-45-6789',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomTextField(
                label: 'Registration Number',
                controller: _registrationNumberController,
                hint: 'Business registration',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return _buildSection(
      title: 'Business Address',
      children: [
        CustomTextField(
          label: 'Street Address',
          controller: _addressController,
          textCapitalization: TextCapitalization.words,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                label: 'City',
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomTextField(
                label: 'State',
                controller: _stateController,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Country',
                controller: _countryController,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomTextField(
                label: 'ZIP Code',
                controller: _zipCodeController,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contact Information',
      children: [
        CustomTextField(
          label: 'Phone Number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return ValidationUtils.validatePhone(value);
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        CustomTextField(
          label: 'Email Address',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              return ValidationUtils.validateEmail(value);
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        CustomTextField(
          label: 'Website',
          controller: _websiteController,
          keyboardType: TextInputType.url,
          hint: 'https://www.example.com',
        ),
      ],
    );
  }

  Widget _buildBusinessSettingsSection() {
    return _buildSection(
      title: 'Business Settings',
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Currency Code',
                controller: _currencyController,
                hint: 'USD, EUR, GBP',
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomTextField(
                label: 'Currency Symbol',
                controller: _currencySymbolController,
                hint: '\$, €, £',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        CustomTextField(
          label: 'Default Tax Rate (%)',
          controller: _defaultTaxRateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: ValidationUtils.validateAmount,
          suffixText: '%',
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Template Theme Dropdown
        _buildThemeDropdown(),
      ],
    );
  }

  Widget _buildAppPreferencesSection() {
    return _buildSection(
      title: 'App Preferences',
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme throughout the app'),
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Language Dropdown
        _buildLanguageDropdown(),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Template Theme',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTheme,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: AppConstants.templateThemes.map((theme) => DropdownMenuItem(
            value: theme,
            child: Text(theme.toUpperCase()),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedTheme = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    final languages = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: languages.entries.map((entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;
    
    if (currentUser == null) {
      NavigationUtils.showSnackBar(
        context,
        'User not found',
        type: SnackBarType.error,
      );
      return;
    }

    // Create updated business info
    final updatedBusinessInfo = BusinessInfo(
      name: _businessNameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim(),
      taxId: _taxIdController.text.trim(),
      registrationNumber: _registrationNumberController.text.trim(),
    );

    // Create updated settings
    final updatedSettings = currentUser.settings.copyWith(
      currency: _currencyController.text.trim(),
      currencySymbol: _currencySymbolController.text.trim(),
      defaultTaxRate: double.tryParse(_defaultTaxRateController.text) ?? 18.0,
      templateTheme: _selectedTheme,
      businessInfo: updatedBusinessInfo,
      darkMode: _darkMode,
      language: _selectedLanguage,
    );

    // Create updated user
    final updatedUser = currentUser.copyWith(
      businessName: _businessNameController.text.trim(),
      settings: updatedSettings,
    );

    final success = await authViewModel.updateProfile(updatedUser);
    
    if (success && mounted) {
      NavigationUtils.showSnackBar(
        context,
        'Business information updated successfully',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else if (mounted) {
      NavigationUtils.showSnackBar(
        context,
        authViewModel.error ?? 'Failed to update business information',
        type: SnackBarType.error,
      );
    }
  }
}