// lib/main.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/services/api_service.dart';
import 'core/services/database_service.dart';
import 'core/services/security_service.dart';
import 'core/services/pdf_service.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/document_viewmodel.dart';
import 'presentation/viewmodels/customer_viewmodel.dart';
import 'presentation/viewmodels/item_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services
  await _initializeServices();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const QuotationMakerApp());
}

Future<void> _initializeServices() async {
  try {
    debugPrint('🚀 Initializing Quotation Maker services...');
    
    // 1. Initialize Security Service (First - needed for encryption)
    final securityService = SecurityService();
    await securityService.initialize();
    
    // 2. Initialize Database
    final databaseHelper = DatabaseHelper();
    await databaseHelper.database; // This will create/open the database
    
    // 3. Initialize Database Service
    final databaseService = DatabaseService();
    await databaseService.initializeWithMockData();
    
    // 4. Initialize Mock API Service (Current data source)
    await MockApiService.initialize();
    
    // 5. Initialize PDF Service
    await PDFService.initialize();
    
    // Log successful initialization
    await securityService.logSecurityEvent(
      event: 'APP_INITIALIZATION',
      details: 'All services initialized successfully',
    );
    
    debugPrint('✅ All services initialized successfully');
    debugPrint('🔒 Security: Enabled with encryption');
    debugPrint('🗄️ Database: Ready (SQLite)');
    debugPrint('📄 PDF Generation: Enhanced service ready');
    debugPrint('🎯 Data Source: Mock API (ready for future DB migration)');
    
  } catch (e) {
    debugPrint('❌ Failed to initialize services: $e');
    // Continue with limited functionality
  }
}

class QuotationMakerApp extends StatelessWidget {
  const QuotationMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core ViewModels - Single source of truth for each domain
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        
        // Services as providers (for easy access in widgets if needed)
        Provider<SecurityService>(create: (_) => SecurityService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Listen for authentication events and log them
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.hasError) {
              SecurityService().logSecurityEvent(
                event: 'AUTH_ERROR',
                details: authViewModel.error ?? 'Unknown auth error',
              );
            }
          });

          return MaterialApp(
            title: 'Quotation Maker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AppWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
            navigatorKey: NavigationService.navigatorKey,
            
            // Global error handling
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(errorDetails);
              };
              return widget ?? const SizedBox();
            },
          );
        },
      ),
    );
  }

  /// Custom error widget for better error handling
  Widget _buildErrorWidget(FlutterErrorDetails errorDetails) {
    // Log the error securely
    SecurityService().logSecurityEvent(
      event: 'APP_ERROR',
      details: errorDetails.toString(),
    );

    return Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The app encountered an error. Please restart the application.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    errorDetails.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}