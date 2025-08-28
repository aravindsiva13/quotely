// main.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart'; // ADD THIS IMPORT
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/document_viewmodel.dart';
import 'presentation/viewmodels/customer_viewmodel.dart';
import 'presentation/viewmodels/item_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
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
    // Initialize API service with mock data
    await MockApiService.initialize();
    debugPrint('✅ Services initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize services: $e');
  }
}

class QuotationMakerApp extends StatelessWidget {
  const QuotationMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ViewModels - Single source of truth for each domain
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerViewModel()),
        ChangeNotifierProvider(create: (_) => ItemViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return MaterialApp(
            title: 'Quotation Maker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const AppWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
            navigatorKey: NavigationService.navigatorKey,
          );
        },
      ),
    );
  }
}