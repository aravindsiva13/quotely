// presentation/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/user.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Controllers for Step 1 - Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers for Step 2 - Business Info
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: AppTextStyles.h4,
        ),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Form Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildPersonalInfoStep(),
                    _buildBusinessInfoStep(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(authViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Personal'),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Business'),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryColor : AppColors.borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.primaryColor : AppColors.textSecondaryColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primaryColor : AppColors.borderColor,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: AppTextStyles.h3,
            ),
            Text(
              'Let\'s start with your basic information',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryColor,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'First Name *',
                    controller: _firstNameController,
                    validator: (value) => ValidationUtils.validateRequired(value, 'First name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomTextField(
                    label: 'Last Name *',
                    controller: _lastNameController,
                    validator: (value) => ValidationUtils.validateRequired(value, 'Last name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            CustomTextField(
              label: 'Email Address *',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmail,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            CustomTextField(
              label: 'Password *',
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: ValidationUtils.validatePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            CustomTextField(
              label: 'Confirm Password *',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return ValidationUtils.validatePassword(value);
              },
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: AppTextStyles.h3,
          ),
          Text(
            'Tell us about your business',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          CustomTextField(
            label: 'Business Name *',
            controller: _businessNameController,
            validator: (value) => ValidationUtils.validateRequired(value, 'Business name'),
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
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
            label: 'Business Address',
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
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmation',
            style: AppTextStyles.h3,
          ),
          Text(
            'Review your information and complete registration',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Personal Info Summary
          _buildSummarySection(
            'Personal Information',
            [
              'Name: ${_firstNameController.text} ${_lastNameController.text}',
              'Email: ${_emailController.text}',
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Business Info Summary
          _buildSummarySection(
            'Business Information',
            [
              'Business: ${_businessNameController.text}',
              if (_phoneController.text.isNotEmpty) 'Phone: ${_phoneController.text}',
              if (_addressController.text.isNotEmpty) 'Address: ${_addressController.text}',
              if (_cityController.text.isNotEmpty) 'Location: ${_cityController.text}, ${_stateController.text}',
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Terms and Conditions
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            title: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: AppTextStyles.bodySmall,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(AuthViewModel authViewModel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                type: ButtonType.outlined,
                onPressed: authViewModel.isLoading ? null : _goToPreviousStep,
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: CustomButton(
              text: _currentStep == 2 ? 'Create Account' : 'Next',
              onPressed: authViewModel.isLoading ? null : _handleNextStep,
              isLoading: authViewModel.isLoading && _currentStep == 2,
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextStep() async {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        _goToNextStep();
      }
    } else if (_currentStep == 1) {
      if (_businessNameController.text.isEmpty) {
        NavigationUtils.showSnackBar(
          context,
          'Business name is required',
          type: SnackBarType.error,
        );
        return;
      }
      _goToNextStep();
    } else if (_currentStep == 2) {
      await _handleRegistration();
    }
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleRegistration() async {
    if (!_acceptTerms) {
      NavigationUtils.showSnackBar(
        context,
        'Please accept the terms and conditions',
        type: SnackBarType.error,
      );
      return;
    }

    final registration = UserRegistration(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      businessName: _businessNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim(),
      country: _countryController.text.trim(),
    );

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(registration);

    if (success && mounted) {
      NavigationUtils.showSnackBar(
        context,
        'Account created successfully! Welcome to Quotation Maker!',
        type: SnackBarType.success,
      );
      // Navigation will be handled automatically by AppWrapper
    } else if (mounted) {
      NavigationUtils.showSnackBar(
        context,
        authViewModel.error ?? 'Registration failed',
        type: SnackBarType.error,
      );
    }
  }
}