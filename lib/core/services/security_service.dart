// lib/core/services/security_service.dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Secure storage instance
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  // Encryption keys and configuration
  static const String _masterKeyAlias = 'quotation_maker_master_key';
  static const String _authTokenKey = 'auth_token';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  
  late Encrypter _encrypter;
  late IV _iv;
  bool _isInitialized = false;

  /// Initialize security service
  Future<void> initialize() async {
    try {
      await _initializeEncryption();
      _isInitialized = true;
      debugPrint('✅ Security service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing security service: $e');
      rethrow;
    }
  }

  /// Initialize encryption with master key
  Future<void> _initializeEncryption() async {
    try {
      // Try to get existing master key
      String? masterKeyString = await _secureStorage.read(key: _masterKeyAlias);
      
      if (masterKeyString == null) {
        // Generate new master key
        final key = Key.fromSecureRandom(32);
        masterKeyString = key.base64;
        await _secureStorage.write(key: _masterKeyAlias, value: masterKeyString);
        debugPrint('🔑 Generated new master key');
      }

      final key = Key.fromBase64(masterKeyString);
      _encrypter = Encrypter(AES(key));
      _iv = IV.fromSecureRandom(16);
      
    } catch (e) {
      debugPrint('❌ Error initializing encryption: $e');
      rethrow;
    }
  }

  // ==================== AUTHENTICATION SECURITY ====================

  /// Hash password with salt
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure salt
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Verify password against hash
  bool verifyPassword(String password, String hash, String salt) {
    final hashedPassword = hashPassword(password, salt);
    return hashedPassword == hash;
  }

  /// Generate secure authentication token
  String generateAuthToken() {
    final random = Random.secure();
    final tokenBytes = List<int>.generate(32, (i) => random.nextInt(256));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tokenWithTimestamp = base64.encode(tokenBytes) + ':' + timestamp.toString();
    return base64.encode(utf8.encode(tokenWithTimestamp));
  }

  /// Validate authentication token
  bool validateAuthToken(String token, {int maxAgeHours = 24}) {
    try {
      final decodedToken = utf8.decode(base64.decode(token));
      final parts = decodedToken.split(':');
      
      if (parts.length != 2) return false;
      
      final timestamp = int.tryParse(parts[1]);
      if (timestamp == null) return false;
      
      final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAgeMs = maxAgeHours * 60 * 60 * 1000;
      
      return tokenAge <= maxAgeMs;
    } catch (e) {
      debugPrint('❌ Error validating auth token: $e');
      return false;
    }
  }

  // ==================== DATA ENCRYPTION ====================

  /// Encrypt sensitive data
  String encryptData(String data) {
    if (!_isInitialized) throw Exception('Security service not initialized');
    
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      debugPrint('❌ Error encrypting data: $e');
      rethrow;
    }
  }

  /// Decrypt sensitive data
  String decryptData(String encryptedData) {
    if (!_isInitialized) throw Exception('Security service not initialized');
    
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      debugPrint('❌ Error decrypting data: $e');
      rethrow;
    }
  }

  /// Encrypt user data for storage
  Map<String, dynamic> encryptUserData(User user) {
    final userData = user.toJson();
    final sensitiveFields = ['email', 'settings'];
    
    for (final field in sensitiveFields) {
      if (userData[field] != null) {
        userData[field] = encryptData(jsonEncode(userData[field]));
      }
    }
    
    return userData;
  }

  /// Decrypt user data from storage
  User decryptUserData(Map<String, dynamic> encryptedUserData) {
    final userData = Map<String, dynamic>.from(encryptedUserData);
    final sensitiveFields = ['email', 'settings'];
    
    for (final field in sensitiveFields) {
      if (userData[field] != null) {
        final decryptedData = decryptData(userData[field] as String);
        userData[field] = jsonDecode(decryptedData);
      }
    }
    
    return User.fromJson(userData);
  }

  // ==================== SECURE STORAGE ====================

  /// Store authentication token securely
  Future<void> storeAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      debugPrint('✅ Auth token stored securely');
    } catch (e) {
      debugPrint('❌ Error storing auth token: $e');
      rethrow;
    }
  }

  /// Retrieve authentication token
  Future<String?> getAuthToken() async {
    try {
      final token = await _secureStorage.read(key: _authTokenKey);
      if (token != null && validateAuthToken(token)) {
        return token;
      }
      // Token is invalid or expired, remove it
      if (token != null) {
        await removeAuthToken();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error retrieving auth token: $e');
      return null;
    }
  }

  /// Remove authentication token
  Future<void> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      debugPrint('✅ Auth token removed');
    } catch (e) {
      debugPrint('❌ Error removing auth token: $e');
    }
  }

  /// Store user credentials securely (for biometric login)
  Future<void> storeUserCredentials({
    required String email,
    required String hashedPassword,
    required String salt,
  }) async {
    try {
      final credentials = {
        'email': email,
        'hashedPassword': hashedPassword,
        'salt': salt,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final encryptedCredentials = encryptData(jsonEncode(credentials));
      await _secureStorage.write(key: _userCredentialsKey, value: encryptedCredentials);
      debugPrint('✅ User credentials stored securely');
    } catch (e) {
      debugPrint('❌ Error storing user credentials: $e');
      rethrow;
    }
  }

  /// Retrieve user credentials
  Future<Map<String, dynamic>?> getUserCredentials() async {
    try {
      final encryptedCredentials = await _secureStorage.read(key: _userCredentialsKey);
      if (encryptedCredentials == null) return null;
      
      final credentialsJson = decryptData(encryptedCredentials);
      return jsonDecode(credentialsJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error retrieving user credentials: $e');
      return null;
    }
  }

  /// Remove stored credentials
  Future<void> removeUserCredentials() async {
    try {
      await _secureStorage.delete(key: _userCredentialsKey);
      debugPrint('✅ User credentials removed');
    } catch (e) {
      debugPrint('❌ Error removing user credentials: $e');
    }
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  /// Check if biometrics are enabled
  Future<bool> isBiometricsEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: _biometricsEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('❌ Error checking biometrics status: $e');
      return false;
    }
  }

  /// Enable biometric authentication
  Future<void> enableBiometrics() async {
    try {
      await _secureStorage.write(key: _biometricsEnabledKey, value: 'true');
      debugPrint('✅ Biometrics enabled');
    } catch (e) {
      debugPrint('❌ Error enabling biometrics: $e');
      rethrow;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometrics() async {
    try {
      await _secureStorage.write(key: _biometricsEnabledKey, value: 'false');
      await removeUserCredentials(); // Remove stored credentials
      debugPrint('✅ Biometrics disabled');
    } catch (e) {
      debugPrint('❌ Error disabling biometrics: $e');
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Create secure session
  Future<String> createSession({
    required String userId,
    required String deviceId,
    int durationHours = 24,
  }) async {
    try {
      final sessionData = {
        'userId': userId,
        'deviceId': deviceId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'expiresAt': DateTime.now().add(Duration(hours: durationHours)).millisecondsSinceEpoch,
        'isActive': true,
      };
      
      final sessionToken = generateAuthToken();
      final encryptedSession = encryptData(jsonEncode(sessionData));
      
      // Store session with token as key
      await _secureStorage.write(key: 'session_$sessionToken', value: encryptedSession);
      
      debugPrint('✅ Secure session created');
      return sessionToken;
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
      rethrow;
    }
  }

  /// Validate session
  Future<bool> validateSession(String sessionToken) async {
    try {
      final encryptedSession = await _secureStorage.read(key: 'session_$sessionToken');
      if (encryptedSession == null) return false;
      
      final sessionJson = decryptData(encryptedSession);
      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      
      final expiresAt = sessionData['expiresAt'] as int;
      final isActive = sessionData['isActive'] as bool;
      
      return isActive && DateTime.now().millisecondsSinceEpoch < expiresAt;
    } catch (e) {
      debugPrint('❌ Error validating session: $e');
      return false;
    }
  }

  /// Invalidate session
  Future<void> invalidateSession(String sessionToken) async {
    try {
      await _secureStorage.delete(key: 'session_$sessionToken');
      debugPrint('✅ Session invalidated');
    } catch (e) {
      debugPrint('❌ Error invalidating session: $e');
    }
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    try {
      final allKeys = await _secureStorage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith('session_')) {
          await _secureStorage.delete(key: key);
        }
      }
      debugPrint('✅ All sessions cleared');
    } catch (e) {
      debugPrint('❌ Error clearing sessions: $e');
    }
  }

  // ==================== DATA VALIDATION & SANITIZATION ====================

  /// Sanitize input to prevent injection attacks
  String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll(RegExp(r'[<>"\']'), '')
        .replaceAll(RegExp(r'script', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .trim();
    
    // Limit length
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }
    
    return sanitized;
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,},
    );
    return emailRegex.hasMatch(email) && email.length <= 100;
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,15});
    return phoneRegex.hasMatch(phone);
  }

  /// Check password strength
  PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.veryWeak;
    if (password.length < 8) return PasswordStrength.weak;
    
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#\  /// Store authentication token securely
  Future*~]'));
    
    int score = 0;
    if (hasLower) score++;
    if (hasUpper) score++;
    if (hasDigit) score++;
    if (hasSpecial) score++;
    if (password.length >= 12) score++;
    
    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.medium;
      case 4:
        return PasswordStrength.strong;
      case 5:
      default:
        return PasswordStrength.veryStrong;
    }
  }

  // ==================== DEVICE SECURITY ====================

  /// Generate device fingerprint
  Future<String> generateDeviceFingerprint() async {
    try {
      // In a real implementation, you'd use device_info_plus
      final random = Random.secure();
      final deviceBytes = List<int>.generate(16, (i) => random.nextInt(256));
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fingerprint = base64.encode(deviceBytes) + timestamp;
      
      return sha256.convert(utf8.encode(fingerprint)).toString();
    } catch (e) {
      debugPrint('❌ Error generating device fingerprint: $e');
      return '';
    }
  }

  /// Check if device is rooted/jailbroken (simplified check)
  Future<bool> isDeviceCompromised() async {
    try {
      // This is a simplified check - in production, use a proper security library
      // Check for common root/jailbreak indicators
      return false; // Placeholder implementation
    } catch (e) {
      debugPrint('❌ Error checking device security: $e');
      return true; // Assume compromised if we can't check
    }
  }

  // ==================== AUDIT LOGGING ====================

  /// Log security events
  Future<void> logSecurityEvent({
    required String event,
    required String details,
    String? userId,
  }) async {
    try {
      final logEntry = {
        'event': event,
        'details': details,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'deviceFingerprint': await generateDeviceFingerprint(),
      };
      
      // In production, send to secure logging service
      debugPrint('🔒 Security Event: $event - $details');
      
      // Store locally for audit trail (encrypted)
      final encryptedLog = encryptData(jsonEncode(logEntry));
      final logKey = 'security_log_${DateTime.now().millisecondsSinceEpoch}';
      await _secureStorage.write(key: logKey, value: encryptedLog);
      
    } catch (e) {
      debugPrint('❌ Error logging security event: $e');
    }
  }

  /// Get security audit logs
  Future<List<Map<String, dynamic>>> getSecurityLogs({int limit = 100}) async {
    try {
      final allKeys = await _secureStorage.readAll();
      final logKeys = allKeys.keys
          .where((key) => key.startsWith('security_log_'))
          .take(limit)
          .toList();
      
      final logs = <Map<String, dynamic>>[];
      
      for (final key in logKeys) {
        final encryptedLog = allKeys[key];
        if (encryptedLog != null) {
          try {
            final logJson = decryptData(encryptedLog);
            logs.add(jsonDecode(logJson) as Map<String, dynamic>);
          } catch (e) {
            debugPrint('❌ Error decrypting log entry: $e');
          }
        }
      }
      
      return logs;
    } catch (e) {
      debugPrint('❌ Error getting security logs: $e');
      return [];
    }
  }

  /// Clear old security logs
  Future<void> clearOldSecurityLogs({int daysOld = 30}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(days: daysOld));
      final allKeys = await _secureStorage.readAll();
      
      for (final key in allKeys.keys) {
        if (key.startsWith('security_log_')) {
          try {
            final timestamp = int.parse(key.split('_').last);
            final logDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            
            if (logDate.isBefore(cutoffTime)) {
              await _secureStorage.delete(key: key);
            }
          } catch (e) {
            debugPrint('❌ Error parsing log timestamp: $e');
          }
        }
      }
      
      debugPrint('✅ Old security logs cleared');
    } catch (e) {
      debugPrint('❌ Error clearing old security logs: $e');
    }
  }

  // ==================== CLEANUP & MAINTENANCE ====================

  /// Clear all secure storage (logout cleanup)
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      _isInitialized = false;
      debugPrint('✅ All secure data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing secure data: $e');
    }
  }

  /// Reset master key (nuclear option)
  Future<void> resetMasterKey() async {
    try {
      await _secureStorage.delete(key: _masterKeyAlias);
      await initialize(); // Reinitialize with new key
      debugPrint('✅ Master key reset');
    } catch (e) {
      debugPrint('❌ Error resetting master key: $e');
      rethrow;
    }
  }

  /// Get storage size for maintenance
  Future<int> getSecureStorageSize() async {
    try {
      final allKeys = await _secureStorage.readAll();
      int totalSize = 0;
      
      for (final value in allKeys.values) {
        totalSize += utf8.encode(value).length;
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('❌ Error calculating storage size: $e');
      return 0;
    }
  }
}

// ==================== ENUMS & MODELS ====================

enum PasswordStrength {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get name {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }
  
  double get score {
    switch (this) {
      case PasswordStrength.veryWeak:
        return 0.2;
      case PasswordStrength.weak:
        return 0.4;
      case PasswordStrength.medium:
        return 0.6;
      case PasswordStrength.strong:
        return 0.8;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}