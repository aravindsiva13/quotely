// data/models/user.dart
import 'dart:convert';

class User {
  final String id;
  final String email;
  final String businessName;
  final String? logoPath;
  final UserSettings settings;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.businessName,
    this.logoPath,
    required this.settings,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      businessName: json['business_name'],
      logoPath: json['logo_path'],
      settings: UserSettings.fromJson(
        json['settings'] is String 
          ? jsonDecode(json['settings']) 
          : json['settings']
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'business_name': businessName,
      'logo_path': logoPath,
      'settings': jsonEncode(settings.toJson()),
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? businessName,
    String? logoPath,
    UserSettings? settings,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      logoPath: logoPath ?? this.logoPath,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserSettings {
  final String currency;
  final String currencySymbol;
  final double defaultTaxRate;
  final String templateTheme;
  final BusinessInfo businessInfo;
  final bool darkMode;
  final String language;

  UserSettings({
    required this.currency,
    required this.currencySymbol,
    required this.defaultTaxRate,
    required this.templateTheme,
    required this.businessInfo,
    this.darkMode = false,
    this.language = 'en',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      currency: json['currency'] ?? 'USD',
      currencySymbol: json['currency_symbol'] ?? '\$',
      defaultTaxRate: (json['default_tax_rate'] ?? 18.0).toDouble(),
      templateTheme: json['template_theme'] ?? 'professional',
      businessInfo: BusinessInfo.fromJson(json['business_info'] ?? {}),
      darkMode: json['dark_mode'] ?? false,
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'currency_symbol': currencySymbol,
      'default_tax_rate': defaultTaxRate,
      'template_theme': templateTheme,
      'business_info': businessInfo.toJson(),
      'dark_mode': darkMode,
      'language': language,
    };
  }

  UserSettings copyWith({
    String? currency,
    String? currencySymbol,
    double? defaultTaxRate,
    String? templateTheme,
    BusinessInfo? businessInfo,
    bool? darkMode,
    String? language,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      templateTheme: templateTheme ?? this.templateTheme,
      businessInfo: businessInfo ?? this.businessInfo,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}

class BusinessInfo {
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;
  final String email;
  final String website;
  final String taxId;
  final String registrationNumber;

  BusinessInfo({
    this.name = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zipCode = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.taxId = '',
    this.registrationNumber = '',
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipCode: json['zip_code'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      taxId: json['tax_id'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'phone': phone,
      'email': email,
      'website': website,
      'tax_id': taxId,
      'registration_number': registrationNumber,
    };
  }

  BusinessInfo copyWith({
    String? name,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? phone,
    String? email,
    String? website,
    String? taxId,
    String? registrationNumber,
  }) {
    return BusinessInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      taxId: taxId ?? this.taxId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
    );
  }
}

class UserRegistration {
  final String email;
  final String password;
  final String businessName;
  final String firstName;
  final String lastName;
  final String phone;
  final String country;

  UserRegistration({
    required this.email,
    required this.password,
    required this.businessName,
    required this.firstName,
    required this.lastName,
    this.phone = '',
    this.country = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'business_name': businessName,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'country': country,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;
  final String? error;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'user': user?.toJson(),
      'message': message,
      'error': error,
    };
  }
}
