// presentation/views/auth/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            // Listen to auth state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (authViewModel.hasError) {
                _showErrorSnackBar(authViewModel.error!);
              }
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    
                    // App Logo & Title
                    _buildHeader(),
                    
                    const SizedBox(height: 60),
                    
                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: ValidationUtils.validateEmail,
                      enabled: !authViewModel.isLoading,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: ValidationUtils.validatePassword,
                      enabled: !authViewModel.isLoading,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    CustomButton(
                      text: 'Login',
                      onPressed: authViewModel.isLoading ? null : _handleLogin,
                      isLoading: authViewModel.isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Demo Login Button
                    CustomButton(
                      text: 'Demo Login',
                      type: ButtonType.outlined,
                      onPressed: authViewModel.isLoading ? null : _handleDemoLogin,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register Link
                    _buildRegisterLink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.receipt_long,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to Quotation Maker',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryColor,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to register screen
          },
          child: Text(
            'Sign up',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      // Navigation is handled automatically by AppWrapper
    }
  }

  Future<void> _handleDemoLogin() async {
    _emailController.text = 'demo@test.com';
    _passwordController.text = 'demo123';
    await _handleLogin();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
