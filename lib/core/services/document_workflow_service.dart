// core/services/document_workflow_service.dart - NEW FILE
import '../constants/app_constants.dart';
import '../../data/models/document.dart';

class DocumentWorkflowService {
  /// Get available next statuses based on current status
  static List<String> getAvailableStatusTransitions(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'draft':
        return ['Draft', 'Sent'];
      case 'sent':
        return ['Sent', 'Viewed', 'Accepted', 'Rejected', 'Cancelled'];
      case 'viewed':
        return ['Viewed', 'Accepted', 'Rejected', 'Cancelled'];
      case 'accepted':
        return ['Accepted', 'Paid', 'Cancelled'];
      case 'rejected':
        return ['Rejected', 'Draft', 'Cancelled'];
      case 'paid':
        return ['Paid']; // Final status
      case 'overdue':
        return ['Overdue', 'Paid', 'Cancelled'];
      case 'cancelled':
        return ['Cancelled', 'Draft']; // Can restart from draft
      default:
        return AppConstants.documentStatuses;
    }
  }

  /// Check if status transition is valid
  static bool isValidStatusTransition(String fromStatus, String toStatus) {
    final availableTransitions = getAvailableStatusTransitions(fromStatus);
    return availableTransitions.contains(toStatus);
  }

  /// Get status color for UI display
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return '#6B7280'; // Gray
      case 'sent':
        return '#3B82F6'; // Blue
      case 'viewed':
        return '#8B5CF6'; // Purple
      case 'accepted':
        return '#10B981'; // Green
      case 'rejected':
        return '#EF4444'; // Red
      case 'paid':
        return '#059669'; // Dark Green
      case 'overdue':
        return '#DC2626'; // Dark Red
      case 'cancelled':
        return '#6B7280'; // Gray
      case 'pending':
        return '#F59E0B'; // Yellow
      default:
        return '#6B7280'; // Default gray
    }
  }

  /// Get status display text
  static String getStatusDisplayText(String status) {
    return status.split(' ').map((word) => 
        word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  /// Check if document is overdue
  static bool isDocumentOverdue(Document document) {
    if (document.dueDate == null || document.status.toLowerCase() == 'paid') {
      return false;
    }
    
    return DateTime.now().isAfter(document.dueDate!);
  }

  /// Auto-update document status based on due date
  static String getAutoUpdatedStatus(Document document) {
    // If document is already paid, don't change status
    if (document.status.toLowerCase() == 'paid') {
      return document.status;
    }
    
    // Check if document should be marked as overdue
    if (isDocumentOverdue(document) && document.status.toLowerCase() != 'overdue') {
      return 'Overdue';
    }
    
    return document.status;
  }

  /// Get status priority for sorting (lower number = higher priority)
  static int getStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return 1;
      case 'rejected':
        return 2;
      case 'accepted':
        return 3;
      case 'viewed':
        return 4;
      case 'sent':
        return 5;
      case 'pending':
        return 6;
      case 'draft':
        return 7;
      case 'paid':
        return 8;
      case 'cancelled':
        return 9;
      default:
        return 10;
    }
  }

  /// Get recommended next action for a document
  static String getRecommendedNextAction(Document document) {
    final status = document.status.toLowerCase();
    
    if (isDocumentOverdue(document) && status != 'paid') {
      return 'Follow up - Document is overdue';
    }
    
    switch (status) {
      case 'draft':
        return 'Send document to customer';
      case 'sent':
        return 'Wait for customer response or follow up';
      case 'viewed':
        return 'Follow up for decision';
      case 'accepted':
        return 'Process payment or delivery';
      case 'rejected':
        return 'Revise document or negotiate terms';
      case 'paid':
        return 'Document completed successfully';
      case 'overdue':
        return 'Send payment reminder';
      case 'cancelled':
        return 'Document cancelled - no action needed';
      default:
        return 'Review document status';
    }
  }

  /// Get status history entry
  static Map<String, dynamic> createStatusHistoryEntry(
    String fromStatus, 
    String toStatus, 
    {String? notes, String? userId}
  ) {
    return {
      'from_status': fromStatus,
      'to_status': toStatus,
      'changed_at': DateTime.now().toIso8601String(),
      'changed_by': userId ?? 'system',
      'notes': notes,
    };
  }

  /// Get document workflow rules
  static Map<String, dynamic> getWorkflowRules(String documentType) {
    // Different document types might have different workflow rules
    switch (documentType.toLowerCase()) {
      case 'quote':
        return {
          'auto_expire_days': 30,
          'reminder_before_expiry_days': 7,
          'allow_edit_after_sent': true,
          'require_approval': false,
        };
      case 'invoice':
        return {
          'auto_overdue_days': 0, // Overdue immediately after due date
          'reminder_before_due_days': 3,
          'allow_edit_after_sent': false,
          'require_approval': false,
        };
      case 'receipt':
        return {
          'final_status': 'paid',
          'allow_edit_after_sent': false,
          'require_approval': false,
        };
      default:
        return {
          'allow_edit_after_sent': true,
          'require_approval': false,
        };
    }
  }

  /// Check if document can be edited based on current status
  static bool canEditDocument(Document document) {
    final rules = getWorkflowRules(document.type);
    final allowEditAfterSent = rules['allow_edit_after_sent'] ?? true;
    
    if (!allowEditAfterSent && !['draft'].contains(document.status.toLowerCase())) {
      return false;
    }
    
    // Paid and cancelled documents generally cannot be edited
    if (['paid', 'cancelled'].contains(document.status.toLowerCase())) {
      return false;
    }
    
    return true;
  }

  /// Check if document can be deleted
  static bool canDeleteDocument(Document document) {
    // Cannot delete paid documents
    if (document.status.toLowerCase() == 'paid') {
      return false;
    }
    
    // Can delete draft and cancelled documents
    if (['draft', 'cancelled'].contains(document.status.toLowerCase())) {
      return true;
    }
    
    // For other statuses, allow deletion with warning
    return true;
  }

  /// Get status badge configuration for UI
  static Map<String, dynamic> getStatusBadgeConfig(String status) {
    final color = getStatusColor(status);
    final displayText = getStatusDisplayText(status);
    
    return {
      'text': displayText,
      'color': color,
      'background_color': color + '20', // 20% opacity
      'icon': _getStatusIcon(status),
    };
  }

  static String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'edit';
      case 'sent':
        return 'send';
      case 'viewed':
        return 'visibility';
      case 'accepted':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'paid':
        return 'payment';
      case 'overdue':
        return 'warning';
      case 'cancelled':
        return 'block';
      case 'pending':
        return 'schedule';
      default:
        return 'info';
    }
  }
}