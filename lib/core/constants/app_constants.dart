 // lib/core/constants/app_constants.dart - COMPLETE VERSION
class AppConstants {
  // App Information
  static const String appName = 'Quotation Maker';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional quotation and invoice maker';
  
  // Default Settings
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
  static const double defaultTaxRate = 18.0;
  static const String defaultLanguage = 'en';
  
  // Document Types
  static const List<String> documentTypes = [
    'Quote',
    'Invoice', 
    'Receipt',
    'Estimate',
    'Proforma'
  ];
  
  // Document Statuses
  static const List<String> documentStatuses = [
    'Draft',
    'Sent',
    'Viewed',
    'Accepted',
    'Rejected',
    'Paid',
    'Overdue',
    'Cancelled'
  ];
  
  // Item Units
  static const List<String> itemUnits = [
    'pcs',      // pieces
    'hours',    // time-based
    'days',
    'weeks',
    'months',
    'years',
    'project',  // project-based
    'service',
    'kg',       // weight
    'lbs',
    'g',
    'oz',
    'meters',   // length
    'feet',
    'cm',
    'inches',
    'sqm',      // area
    'sqft',
    'liters',   // volume
    'gallons',
    'ml',
    'boxes',    // packaging
    'cartons',
    'packages',
    'units',
    'sets',
    'pairs',
    'dozen',
  ];
  
  // Template Themes
  static const List<String> templateThemes = [
    'professional',
    'modern',
    'classic',
    'minimal',
    'creative',
    'corporate'
  ];
  
  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français', 
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'nl': 'Nederlands',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
  };
  
  // Supported Currencies
  static const Map<String, String> supportedCurrencies = {
    'USD': '\$',  // US Dollar
    'EUR': '€',   // Euro
    'GBP': '£',   // British Pound
    'JPY': '¥',   // Japanese Yen
    'CAD': 'C\$', // Canadian Dollar
    'AUD': 'A\$', // Australian Dollar
    'CHF': 'Fr',  // Swiss Franc
    'CNY': '¥',   // Chinese Yuan
    'INR': '₹',   // Indian Rupee
    'BRL': 'R\$', // Brazilian Real
    'RUB': '₽',   // Russian Ruble
    'KRW': '₩',   // South Korean Won
    'SEK': 'kr',  // Swedish Krona
    'NOK': 'kr',  // Norwegian Krone
    'DKK': 'kr',  // Danish Krone
    'PLN': 'zł',  // Polish Zloty
    'CZK': 'Kč',  // Czech Koruna
    'HUF': 'Ft',  // Hungarian Forint
  };
  
  // Business Types
  static const List<String> businessTypes = [
    'Sole Proprietorship',
    'Partnership', 
    'Corporation',
    'LLC',
    'Non-Profit',
    'Freelancer',
    'Consultant',
    'Other'
  ];
  
  // Industry Categories
  static const List<String> industryCategories = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Construction',
    'Manufacturing',
    'Retail',
    'Food & Beverage',
    'Transportation',
    'Real Estate',
    'Entertainment',
    'Legal',
    'Marketing',
    'Design',
    'Consulting',
    'Other'
  ];
  
  // Payment Terms
  static const List<String> paymentTerms = [
    'Due immediately',
    'Net 15 days',
    'Net 30 days',
    'Net 45 days',
    'Net 60 days',
    'Due on receipt',
    'Cash on delivery',
    'Prepayment required',
  ];
  
  // Tax Rates (Common)
  static const Map<String, double> commonTaxRates = {
    'No Tax': 0.0,
    'GST (5%)': 5.0,
    'HST (13%)': 13.0,
    'VAT (20%)': 20.0,
    'Sales Tax (8.5%)': 8.5,
    'Service Tax (18%)': 18.0,
  };
  
  // File Formats
  static const List<String> exportFormats = [
    'PDF',
    'JSON',
    'CSV',
    'Excel'
  ];
  
  // Date Formats  
  static const Map<String, String> dateFormats = {
    'MM/dd/yyyy': 'US Format (MM/dd/yyyy)',
    'dd/MM/yyyy': 'EU Format (dd/MM/yyyy)',
    'yyyy-MM-dd': 'ISO Format (yyyy-MM-dd)',
    'MMM dd, yyyy': 'Long Format (MMM dd, yyyy)',
    'dd MMM yyyy': 'Alt Long Format (dd MMM yyyy)',
  };
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 1000;
  static const double maxAmount = 999999999.99;
  static const double minAmount = 0.01;
  
  // UI Constants
  static const double maxDialogWidth = 600.0;
  static const int itemsPerPage = 20;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Storage Constants
  static const int maxBackupFiles = 10;
  static const int maxExportFiles = 5;
  static const String backupFileExtension = '.qmbackup';
  static const String exportFileExtension = '.qmexport';
  
  // Demo Data
  static const String demoEmail = 'demo@test.com';
  static const String demoPassword = 'demo123';
  static const String demoBusinessName = 'Demo Business Inc';
}