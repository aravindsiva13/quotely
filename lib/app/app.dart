// app/app.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/auth/splash_view.dart';
import '../presentation/views/main_navigation_view.dart';
import '../data/models/user.dart';
import '../data/models/customer.dart';
import '../data/models/document.dart';
import '../data/models/item.dart';
import '../presentation/views/documents/document_create_view.dart';
import '../presentation/views/documents/document_view.dart';
import '../presentation/views/customers/customer_form_view.dart';
import '../presentation/views/customers/customer_detail_view.dart';
import '../presentation/views/items/item_form_view.dart';
import '../presentation/views/settings/business_info_view.dart';

// App Wrapper - Determines initial route based on auth state
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show splash while checking auth state
        if (authViewModel.isInitializing) {
          return const SplashView();
        }
        
        // Navigate to main app or login based on auth state
        return authViewModel.isAuthenticated 
          ? const MainNavigationView()
          : const LoginView();
      },
    );
  }
}

// Navigation Service - Centralized navigation management
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get context => navigatorKey.currentContext;
  
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
  
  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }
  
  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName, 
    bool Function(Route<dynamic>) predicate, 
    {Object? arguments}
  ) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName, 
      predicate, 
      arguments: arguments
    );
  }
}

// App Router - Centralized route management
class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String documentCreate = '/document/create';
  static const String documentEdit = '/document/edit';
  static const String documentView = '/document/view';
  static const String customerCreate = '/customer/create';
  static const String customerEdit = '/customer/edit';
  static const String customerDetail = '/customer/detail';
  static const String itemCreate = '/item/create';
  static const String itemEdit = '/item/edit';
  static const String settings = '/settings';
  static const String businessInfo = '/settings/business-info';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashView());
        
      case login:
        return _buildRoute(const LoginView());
        
      case main:
        return _buildRoute(const MainNavigationView());
        
      case documentCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        final customer = args?['customer'] as Customer?;
        return _buildRoute(DocumentCreateView(preselectedCustomer: customer));
        
      case documentEdit:
        final document = settings.arguments as Document?;
        return _buildRoute(DocumentCreateView(document: document));
        
      case documentView:
        final document = settings.arguments as Document;
        return _buildRoute(DocumentView(document: document));
        
      case customerCreate:
        return _buildRoute(const CustomerFormView());
        
      case customerEdit:
        final customer = settings.arguments as Customer?;
        return _buildRoute(CustomerFormView(customer: customer));
        
      case customerDetail:
        final customer = settings.arguments as Customer;
        return _buildRoute(CustomerDetailView(customer: customer));
        
      case itemCreate:
        return _buildRoute(const ItemFormView());
        
      case itemEdit:
        final item = settings.arguments as Item?;
        return _buildRoute(ItemFormView(item: item));
        
      case businessInfo:
        return _buildRoute(const BusinessInfoView());
        
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  static MaterialPageRoute<dynamic> _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

// Route Constants
class Routes {
  static const String splash = AppRouter.splash;
  static const String login = AppRouter.login;
  static const String main = AppRouter.main;
  static const String documentCreate = AppRouter.documentCreate;
  static const String documentEdit = AppRouter.documentEdit;
  static const String documentView = AppRouter.documentView;
  static const String customerCreate = AppRouter.customerCreate;
  static const String customerEdit = AppRouter.customerEdit;
  static const String customerDetail = AppRouter.customerDetail;
  static const String itemCreate = AppRouter.itemCreate;
  static const String itemEdit = AppRouter.itemEdit;
  static const String businessInfo = AppRouter.businessInfo;
}