// lib/app/routes.dart
import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../data/models/customer.dart';
import '../data/models/document.dart';
import '../data/models/item.dart';
import '../presentation/views/auth/splash_view.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/auth/register_view.dart';
import '../presentation/views/main_navigation_view.dart';
import '../presentation/views/dashboard/dashboard_view.dart';
import '../presentation/views/documents/document_list_view.dart';
import '../presentation/views/documents/document_create_view.dart';
import '../presentation/views/documents/document_view.dart';
import '../presentation/views/customers/customer_list_view.dart';
import '../presentation/views/customers/customer_form_view.dart';
import '../presentation/views/customers/customer_detail_view.dart';
import '../presentation/views/items/item_list_view.dart';
import '../presentation/views/items/item_form_view.dart';
import '../presentation/views/settings/settings_view.dart';
import '../presentation/views/settings/business_info_view.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  
  // Document routes
  static const String documentList = '/documents';
  static const String documentCreate = '/document/create';
  static const String documentEdit = '/document/edit';
  static const String documentView = '/document/view';
  
  // Customer routes
  static const String customerList = '/customers';
  static const String customerCreate = '/customer/create';
  static const String customerEdit = '/customer/edit';
  static const String customerDetail = '/customer/detail';
  
  // Item routes
  static const String itemList = '/items';
  static const String itemCreate = '/item/create';
  static const String itemEdit = '/item/edit';
  
  // Settings routes
  static const String settings = '/settings';
  static const String businessInfo = '/settings/business-info';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(const SplashView());
        
      case login:
        return _createRoute(const LoginView());
        
      case register:
        return _createRoute(const RegisterView());
        
      case main:
        return _createRoute(const MainNavigationView());
        
      case dashboard:
        return _createRoute(const DashboardView());
        
      // Document routes
      case documentList:
        return _createRoute(const DocumentListView());
        
      case documentCreate:
        final args = settings.arguments as Map<String, dynamic>?;
        final customer = args?['customer'] as Customer?;
        return _createRoute(DocumentCreateView(preselectedCustomer: customer));
        
      case documentEdit:
        final document = settings.arguments as Document;
        return _createRoute(DocumentCreateView(document: document));
        
      case documentView:
        final document = settings.arguments as Document;
        return _createRoute(DocumentView(document: document));
        
      // Customer routes
      case customerList:
        return _createRoute(const CustomerListView());
        
      case customerCreate:
        return _createRoute(const CustomerFormView());
        
      case customerEdit:
        final customer = settings.arguments as Customer;
        return _createRoute(CustomerFormView(customer: customer));
        
      case customerDetail:
        final customer = settings.arguments as Customer;
        return _createRoute(CustomerDetailView(customer: customer));
        
      // Item routes
      case itemList:
        return _createRoute(const ItemListView());
        
      case itemCreate:
        return _createRoute(const ItemFormView());
        
      case itemEdit:
        final item = settings.arguments as Item;
        return _createRoute(ItemFormView(item: item));
        
      // Settings routes
      case settings:
        return _createRoute(const SettingsView());
        
      case businessInfo:
        return _createRoute(const BusinessInfoView());
        
      default:
        return _createRoute(
          Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
            ),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Create route with slide transition
  static PageRouteBuilder<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Navigation helper methods
  static Future<T?> pushNamed<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context, 
    String routeName, 
    bool Function(Route<dynamic>) predicate, 
    {Object? arguments}
  ) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      predicate, 
      arguments: arguments
    );
  }

  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}