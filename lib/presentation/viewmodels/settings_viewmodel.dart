// lib/presentation/viewmodels/settings_viewmodel.dart
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/storage_service.dart';
import 'base_viewmodel.dart';

class SettingsViewModel extends BaseViewModel {
  final AuthRepository _authRepository = AuthRepository();
  
  User? _currentUser;
  Map<String, dynamic> _appSettings = {};

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic> get appSettings => _appSettings;
  
  // Theme settings
  bool get isDarkMode => _appSettings['dark_mode'] ?? false;
  String get selectedLanguage => _appSettings['language'] ?? 'en';
  String get selectedTheme => _appSettings['theme'] ?? 'system';
  
  // Notification settings
  bool get notificationsEnabled => _appSettings['notifications_enabled'] ?? true;
  bool get emailNotifications => _appSettings['email_notifications'] ?? true;
  bool get pushNotifications => _appSettings['push_notifications'] ?? true;
  
  // Privacy settings
  bool get analyticsEnabled => _appSettings['analytics_enabled'] ?? true;
  bool get crashReportingEnabled => _appSettings['crash_reporting_enabled'] ?? true;
  
  // Backup settings
  bool get autoBackupEnabled => _appSettings['auto_backup_enabled'] ?? false;
  int get backupFrequency => _appSettings['backup_frequency'] ?? 7; // days

  SettingsViewModel() {
    loadSettings();
  }

  /// Load all settings
  Future<void> loadSettings() async {
    try {
      setLoading(true);
      clearError();
      
      // Load current user
      _currentUser = await _authRepository.getCurrentUser();
      
      // Load app settings
      _appSettings = await StorageService.loadAppSettings();
      
      setState();
    } catch (e) {
      setError('Failed to load settings: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Update theme settings
  Future<bool> updateThemeSettings({
    bool? darkMode,
    String? language,
    String? theme,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedSettings = Map<String, dynamic>.from(_appSettings);
      
      if (darkMode != null) {
        updatedSettings['dark_mode'] = darkMode;
      }
      if (language != null) {
        updatedSettings['language'] = language;
      }
      if (theme != null) {
        updatedSettings['theme'] = theme;
      }
      
      await StorageService.saveAppSettings(updatedSettings);
      _appSettings = updatedSettings;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to update theme settings: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedSettings = Map<String, dynamic>.from(_appSettings);
      
      if (notificationsEnabled != null) {
        updatedSettings['notifications_enabled'] = notificationsEnabled;
      }
      if (emailNotifications != null) {
        updatedSettings['email_notifications'] = emailNotifications;
      }
      if (pushNotifications != null) {
        updatedSettings['push_notifications'] = pushNotifications;
      }
      
      await StorageService.saveAppSettings(updatedSettings);
      _appSettings = updatedSettings;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to update notification settings: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedSettings = Map<String, dynamic>.from(_appSettings);
      
      if (analyticsEnabled != null) {
        updatedSettings['analytics_enabled'] = analyticsEnabled;
      }
      if (crashReportingEnabled != null) {
        updatedSettings['crash_reporting_enabled'] = crashReportingEnabled;
      }
      
      await StorageService.saveAppSettings(updatedSettings);
      _appSettings = updatedSettings;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to update privacy settings: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update backup settings
  Future<bool> updateBackupSettings({
    bool? autoBackupEnabled,
    int? backupFrequency,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedSettings = Map<String, dynamic>.from(_appSettings);
      
      if (autoBackupEnabled != null) {
        updatedSettings['auto_backup_enabled'] = autoBackupEnabled;
      }
      if (backupFrequency != null) {
        updatedSettings['backup_frequency'] = backupFrequency;
      }
      
      await StorageService.saveAppSettings(updatedSettings);
      _appSettings = updatedSettings;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to update backup settings: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Create backup
  Future<String?> createBackup() async {
    try {
      setLoading(true);
      clearError();
      
      final backupPath = await StorageService.createBackup();
      
      setState();
      return backupPath;
    } catch (e) {
      setError('Failed to create backup: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Get available backups
  Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      setLoading(true);
      clearError();
      
      final backups = await StorageService.getAvailableBackups();
      
      setState();
      return backups;
    } catch (e) {
      setError('Failed to get available backups: $e');
      return [];
    } finally {
      setLoading(false);
    }
  }

  /// Restore from backup
  Future<bool> restoreFromBackup(String backupPath) async {
    try {
      setLoading(true);
      clearError();
      
      await StorageService.restoreFromBackup(backupPath);
      
      // Reload settings after restore
      await loadSettings();
      
      return true;
    } catch (e) {
      setError('Failed to restore from backup: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete backup
  Future<bool> deleteBackup(String backupPath) async {
    try {
      await StorageService.deleteBackup(backupPath);
      return true;
    } catch (e) {
      setError('Failed to delete backup: $e');
      return false;
    }
  }

  /// Get storage statistics
  Future<StorageStats?> getStorageStats() async {
    try {
      setLoading(true);
      clearError();
      
      final stats = await StorageService.getStorageStats();
      
      setState();
      return stats;
    } catch (e) {
      setError('Failed to get storage statistics: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Export data
  Future<String?> exportData({
    bool includeCustomers = true,
    bool includeDocuments = true,
    bool includeItems = true,
  }) async {
    try {
      setLoading(true);
      clearError();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'quotation_maker_export_$timestamp';
      
      final exportPath = await StorageService.exportToFile(
        fileName: fileName,
        includeCustomers: includeCustomers,
        includeDocuments: includeDocuments,
        includeItems: includeItems,
      );
      
      setState();
      return exportPath;
    } catch (e) {
      setError('Failed to export data: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Import data
  Future<ImportResult?> importData(String filePath) async {
    try {
      setLoading(true);
      clearError();
      
      final result = await StorageService.importFromFile(filePath);
      
      setState();
      return result;
    } catch (e) {
      setError('Failed to import data: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    try {
      setLoading(true);
      clearError();
      
      await StorageService.clearAllData();
      
      // Reset local state
      _currentUser = null;
      _appSettings = {};
      
      setState();
      return true;
    } catch (e) {
      setError('Failed to clear all data: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Reset app settings to defaults
  Future<bool> resetToDefaults() async {
    try {
      setLoading(true);
      clearError();
      
      final defaultSettings = <String, dynamic>{
        'dark_mode': false,
        'language': 'en',
        'theme': 'system',
        'notifications_enabled': true,
        'email_notifications': true,
        'push_notifications': true,
        'analytics_enabled': true,
        'crash_reporting_enabled': true,
        'auto_backup_enabled': false,
        'backup_frequency': 7,
      };
      
      await StorageService.saveAppSettings(defaultSettings);
      _appSettings = defaultSettings;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to reset settings: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(User updatedUser) async {
    try {
      setLoading(true);
      clearError();
      
      final result = await _authRepository.updateProfile(updatedUser);
      _currentUser = result;
      setState();
      
      return true;
    } catch (e) {
      setError('Failed to update user profile: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Get app version info
  String get appVersion => '1.0.0';
  String get buildNumber => '1';
  
  /// Get device info placeholder (would use device_info_plus in real app)
  Map<String, String> get deviceInfo => {
    'platform': 'Flutter',
    'version': 'SDK 3.0.0',
    'device': 'Universal',
  };
}