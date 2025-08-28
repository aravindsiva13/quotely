// presentation/views/customers/customer_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/customer.dart';

class CustomerFormView extends StatefulWidget {
  final Customer? customer; // null for create, existing customer for edit

  const CustomerFormView({super.key, this.customer});

  @override
  State<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _zipCodeController;
  late TextEditingController _notesController;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final customer = widget.customer;
    
    _nameController = TextEditingController(text: customer?.name ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _addressController = TextEditingController(text: customer?.address ?? '');
    _cityController = TextEditingController(text: customer?.city ?? '');
    _stateController = TextEditingController(text: customer?.state ?? '');
    _countryController = TextEditingController(text: customer?.country ?? '');
    _zipCodeController = TextEditingController(text: customer?.zipCode ?? '');
    _notesController = TextEditingController(text: customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Customer' : 'Add Customer',
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, customerViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Information Section
                  _buildSectionHeader('Basic Information'),
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Customer Name *',
                    controller: _nameController,
                    validator: (value) => ValidationUtils.validateRequired(value, 'Customer name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Email',
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
                    label: 'Phone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return ValidationUtils.validatePhone(value);
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Address Section
                  _buildSectionHeader('Address Information'),
                  const SizedBox(height: AppSpacing.md),
                  
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
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Notes Section
                  _buildSectionHeader('Additional Notes'),
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomTextField(
                    label: 'Notes',
                    controller: _notesController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Action Buttons
                  CustomButton(
                    text: isEditing ? 'Update Customer' : 'Create Customer',
                    onPressed: customerViewModel.isLoading ? null : _handleSave,
                    isLoading: customerViewModel.isLoading,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  CustomButton(
                    text: 'Cancel',
                    type: ButtonType.outlined,
                    onPressed: customerViewModel.isLoading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customerViewModel = context.read<CustomerViewModel>();
    final customer = Customer(
      id: widget.customer?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await customerViewModel.updateCustomer(customer);
    } else {
      success = await customerViewModel.createCustomer(customer);
    }

    if (success && mounted) {
      NavigationUtils.showSnackBar(
        context,
        isEditing ? 'Customer updated successfully' : 'Customer created successfully',
        type: SnackBarType.success,
      );
      Navigator.pop(context);
    } else if (mounted) {
      NavigationUtils.showSnackBar(
        context,
        customerViewModel.error ?? 'Failed to save customer',
        type: SnackBarType.error,
      );
    }
  }
}