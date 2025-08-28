// core/services/pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../../data/models/document.dart';
import '../../data/models/customer.dart';
import '../../data/models/user.dart';

class PDFService {
  static const String _pdfTemplate = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{DOCUMENT_TYPE}} {{DOCUMENT_NUMBER}}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            font-size: 12px;
            line-height: 1.4;
            color: #333;
            background: white;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 2px solid #2563EB;
        }
        
        .logo-section {
            flex: 1;
        }
        
        .document-info {
            text-align: right;
            flex: 1;
        }
        
        .document-title {
            font-size: 28px;
            font-weight: bold;
            color: #2563EB;
            margin-bottom: 5px;
        }
        
        .document-number {
            font-size: 16px;
            color: #666;
            margin-bottom: 10px;
        }
        
        .status {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status.draft { background: #F3F4F6; color: #6B7280; }
        .status.sent { background: #FEF3C7; color: #D97706; }
        .status.paid { background: #D1FAE5; color: #059669; }
        .status.overdue { background: #FEE2E2; color: #DC2626; }
        
        .parties {
            display: flex;
            justify-content: space-between;
            margin-bottom: 40px;
        }
        
        .party {
            flex: 1;
            margin-right: 40px;
        }
        
        .party:last-child {
            margin-right: 0;
        }
        
        .party-title {
            font-size: 14px;
            font-weight: bold;
            color: #2563EB;
            margin-bottom: 10px;
            text-transform: uppercase;
        }
        
        .party-info {
            line-height: 1.6;
        }
        
        .company-name {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .dates {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            background: #F9FAFB;
            padding: 15px;
            border-radius: 8px;
        }
        
        .date-item {
            text-align: center;
        }
        
        .date-label {
            font-size: 11px;
            color: #6B7280;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        
        .date-value {
            font-size: 14px;
            font-weight: bold;
            color: #111827;
        }
        
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        
        .items-table th,
        .items-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #E5E7EB;
        }
        
        .items-table th {
            background: #F9FAFB;
            font-weight: bold;
            color: #374151;
            text-transform: uppercase;
            font-size: 11px;
        }
        
        .items-table td {
            font-size: 12px;
        }
        
        .text-right {
            text-align: right;
        }
        
        .text-center {
            text-align: center;
        }
        
        .item-description {
            color: #6B7280;
            font-size: 11px;
            margin-top: 2px;
        }
        
        .summary {
            margin-left: auto;
            width: 300px;
        }
        
        .summary-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .summary-table td {
            padding: 8px 12px;
            border-bottom: 1px solid #F3F4F6;
        }
        
        .summary-table .label {
            color: #6B7280;
            font-weight: normal;
        }
        
        .summary-table .amount {
            text-align: right;
            font-weight: bold;
        }
        
        .total-row {
            background: #F9FAFB;
            border-top: 2px solid #2563EB;
        }
        
        .total-row td {
            font-size: 16px;
            font-weight: bold;
            color: #2563EB;
        }
        
        .notes-section {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #E5E7EB;
        }
        
        .section-title {
            font-size: 14px;
            font-weight: bold;
            color: #2563EB;
            margin-bottom: 10px;
            text-transform: uppercase;
        }
        
        .notes-content {
            background: #F9FAFB;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #2563EB;
            line-height: 1.6;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #E5E7EB;
            text-align: center;
            color: #6B7280;
            font-size: 11px;
        }
        
        @media print {
            body { margin: 0; }
            .container { padding: 20px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header Section -->
        <div class="header">
            <div class="logo-section">
                <div class="company-name">{{BUSINESS_NAME}}</div>
                <div>{{BUSINESS_ADDRESS}}</div>
                <div>{{BUSINESS_CONTACT}}</div>
            </div>
            <div class="document-info">
                <div class="document-title">{{DOCUMENT_TYPE}}</div>
                <div class="document-number">{{DOCUMENT_NUMBER}}</div>
                <div class="status {{STATUS_CLASS}}">{{STATUS}}</div>
            </div>
        </div>
        
        <!-- Parties Section -->
        <div class="parties">
            <div class="party">
                <div class="party-title">From</div>
                <div class="party-info">
                    <div class="company-name">{{FROM_NAME}}</div>
                    <div>{{FROM_ADDRESS}}</div>
                    <div>{{FROM_CITY_STATE_ZIP}}</div>
                    <div>{{FROM_COUNTRY}}</div>
                    {{FROM_CONTACT}}
                </div>
            </div>
            <div class="party">
                <div class="party-title">To</div>
                <div class="party-info">
                    <div class="company-name">{{TO_NAME}}</div>
                    <div>{{TO_ADDRESS}}</div>
                    <div>{{TO_CITY_STATE_ZIP}}</div>
                    <div>{{TO_COUNTRY}}</div>
                    {{TO_CONTACT}}
                </div>
            </div>
        </div>
        
        <!-- Dates Section -->
        <div class="dates">
            <div class="date-item">
                <div class="date-label">{{DATE_LABEL}}</div>
                <div class="date-value">{{DOCUMENT_DATE}}</div>
            </div>
            {{DUE_DATE_SECTION}}
        </div>
        
        <!-- Items Table -->
        <table class="items-table">
            <thead>
                <tr>
                    <th style="width: 50%;">Description</th>
                    <th style="width: 15%;" class="text-center">Qty</th>
                    <th style="width: 15%;" class="text-right">Rate</th>
                    <th style="width: 20%;" class="text-right">Amount</th>
                </tr>
            </thead>
            <tbody>
                {{ITEMS_ROWS}}
            </tbody>
        </table>
        
        <!-- Summary -->
        <div class="summary">
            <table class="summary-table">
                <tr>
                    <td class="label">Subtotal</td>
                    <td class="amount">{{SUBTOTAL}}</td>
                </tr>
                {{DISCOUNT_ROW}}
                <tr>
                    <td class="label">Tax</td>
                    <td class="amount">{{TAX_AMOUNT}}</td>
                </tr>
                <tr class="total-row">
                    <td class="label">Total</td>
                    <td class="amount">{{TOTAL_AMOUNT}}</td>
                </tr>
            </table>
        </div>
        
        <!-- Notes and Terms -->
        {{NOTES_SECTION}}
        {{TERMS_SECTION}}
        
        <!-- Footer -->
        <div class="footer">
            <div>Generated on {{GENERATED_DATE}} by Quotation Maker</div>
            {{BUSINESS_FOOTER}}
        </div>
    </div>
</body>
</html>
''';

  /// Generates a PDF for the given document
  static Future<Uint8List> generateDocumentPDF({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    try {
      // Since we can't use actual PDF libraries in this context,
      // we'll create an HTML representation that can be converted to PDF
      final html = _generateHTMLContent(
        document: document,
        customer: customer,
        user: user,
      );
      
      // In a real implementation, you would use a library like:
      // - pdf package for pure Dart PDF generation
      // - printing package for Flutter PDF generation
      // - flutter_html_to_pdf for HTML to PDF conversion
      
      // For now, we'll return the HTML as bytes
      // This is a mock implementation
      return Uint8List.fromList(html.codeUnits);
      
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Generates HTML content for the document
  static String _generateHTMLContent({
    required Document document,
    required Customer customer,
    required User user,
  }) {
    final businessInfo = user.settings.businessInfo;
    
    String html = _pdfTemplate;
    
    // Replace document info
    html = html.replaceAll('{{DOCUMENT_TYPE}}', document.type.toUpperCase());
    html = html.replaceAll('{{DOCUMENT_NUMBER}}', document.number);
    html = html.replaceAll('{{STATUS}}', document.status);
    html = html.replaceAll('{{STATUS_CLASS}}', document.status.toLowerCase());
    
    // Replace business info
    html = html.replaceAll('{{BUSINESS_NAME}}', user.businessName);
    html = html.replaceAll('{{BUSINESS_ADDRESS}}', _formatBusinessAddress(businessInfo));
    html = html.replaceAll('{{BUSINESS_CONTACT}}', _formatBusinessContact(businessInfo));
    
    // Replace from/to info
    html = html.replaceAll('{{FROM_NAME}}', businessInfo.name);
    html = html.replaceAll('{{FROM_ADDRESS}}', businessInfo.address);
    html = html.replaceAll('{{FROM_CITY_STATE_ZIP}}', '${businessInfo.city}, ${businessInfo.state} ${businessInfo.zipCode}');
    html = html.replaceAll('{{FROM_COUNTRY}}', businessInfo.country);
    html = html.replaceAll('{{FROM_CONTACT}}', _formatContactInfo(businessInfo.phone, businessInfo.email));
    
    html = html.replaceAll('{{TO_NAME}}', customer.name);
    html = html.replaceAll('{{TO_ADDRESS}}', customer.address);
    html = html.replaceAll('{{TO_CITY_STATE_ZIP}}', '${customer.city}, ${customer.state} ${customer.zipCode}');
    html = html.replaceAll('{{TO_COUNTRY}}', customer.country);
    html = html.replaceAll('{{TO_CONTACT}}', _formatContactInfo(customer.phone, customer.email));
    
    // Replace dates
    html = html.replaceAll('{{DATE_LABEL}}', document.type == 'Invoice' ? 'Invoice Date' : 'Date');
    html = html.replaceAll('{{DOCUMENT_DATE}}', AppDateUtils.formatDate(document.date));
    
    if (document.dueDate != null) {
      final dueDateSection = '''
      <div class="date-item">
          <div class="date-label">Due Date</div>
          <div class="date-value">${AppDateUtils.formatDate(document.dueDate!)}</div>
      </div>
      ''';
      html = html.replaceAll('{{DUE_DATE_SECTION}}', dueDateSection);
    } else {
      html = html.replaceAll('{{DUE_DATE_SECTION}}', '');
    }
    
    // Replace items
    html = html.replaceAll('{{ITEMS_ROWS}}', _generateItemsRows(document.items, document.currencySymbol));
    
    // Replace amounts
    html = html.replaceAll('{{SUBTOTAL}}', CurrencyUtils.formatAmount(document.subtotal, document.currencySymbol));
    html = html.replaceAll('{{TAX_AMOUNT}}', CurrencyUtils.formatAmount(document.taxAmount, document.currencySymbol));
    html = html.replaceAll('{{TOTAL_AMOUNT}}', CurrencyUtils.formatAmount(document.total, document.currencySymbol));
    
    // Handle discount
    if (document.discountAmount > 0) {
      final discountRow = '''
      <tr>
          <td class="label">Discount</td>
          <td class="amount">-${CurrencyUtils.formatAmount(document.discountAmount, document.currencySymbol)}</td>
      </tr>
      ''';
      html = html.replaceAll('{{DISCOUNT_ROW}}', discountRow);
    } else {
      html = html.replaceAll('{{DISCOUNT_ROW}}', '');
    }
    
    // Replace notes and terms
    html = html.replaceAll('{{NOTES_SECTION}}', _generateNotesSection(document.notes));
    html = html.replaceAll('{{TERMS_SECTION}}', _generateTermsSection(document.terms));
    
    // Replace footer
    html = html.replaceAll('{{GENERATED_DATE}}', AppDateUtils.formatDateTime(DateTime.now()));
    html = html.replaceAll('{{BUSINESS_FOOTER}}', _generateBusinessFooter(businessInfo));
    
    return html;
  }

  static String _formatBusinessAddress(BusinessInfo info) {
    final parts = <String>[];
    if (info.address.isNotEmpty) parts.add(info.address);
    if (info.city.isNotEmpty) parts.add('${info.city}, ${info.state} ${info.zipCode}');
    if (info.country.isNotEmpty) parts.add(info.country);
    return parts.join('<br>');
  }

  static String _formatBusinessContact(BusinessInfo info) {
    final parts = <String>[];
    if (info.phone.isNotEmpty) parts.add('Tel: ${info.phone}');
    if (info.email.isNotEmpty) parts.add('Email: ${info.email}');
    if (info.website.isNotEmpty) parts.add('Web: ${info.website}');
    return parts.join('<br>');
  }

  static String _formatContactInfo(String phone, String email) {
    final parts = <String>[];
    if (phone.isNotEmpty) parts.add('<div>Phone: $phone</div>');
    if (email.isNotEmpty) parts.add('<div>Email: $email</div>');
    return parts.join('');
  }

  static String _generateItemsRows(List<DocumentItem> items, String currencySymbol) {
    return items.map((item) {
      final description = item.description.isNotEmpty 
        ? '${item.name}<div class="item-description">${item.description}</div>'
        : item.name;
      
      return '''
      <tr>
          <td>$description</td>
          <td class="text-center">${item.quantity} ${item.unit}</td>
          <td class="text-right">${CurrencyUtils.formatAmount(item.unitPrice, currencySymbol)}</td>
          <td class="text-right">${CurrencyUtils.formatAmount(item.total, currencySymbol)}</td>
      </tr>
      ''';
    }).join('');
  }

  static String _generateNotesSection(String? notes) {
    if (notes == null || notes.isEmpty) return '';
    
    return '''
    <div class="notes-section">
        <div class="section-title">Notes</div>
        <div class="notes-content">$notes</div>
    </div>
    ''';
  }

  static String _generateTermsSection(String? terms) {
    if (terms == null || terms.isEmpty) return '';
    
    return '''
    <div class="notes-section">
        <div class="section-title">Terms & Conditions</div>
        <div class="notes-content">$terms</div>
    </div>
    ''';
  }

  static String _generateBusinessFooter(BusinessInfo info) {
    final parts = <String>[];
    if (info.taxId.isNotEmpty) parts.add('Tax ID: ${info.taxId}');
    if (info.registrationNumber.isNotEmpty) parts.add('Reg. No: ${info.registrationNumber}');
    
    return parts.isNotEmpty 
      ? '<div style="margin-top: 10px;">${parts.join(' | ')}</div>'
      : '';
  }

  /// Saves the PDF to device storage
  static Future<String> savePDFToDevice({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/pdfs/$fileName.pdf');
      
      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);
      
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  /// Shares the PDF document
  static Future<void> shareDocument({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    try {
      final pdfBytes = await generateDocumentPDF(
        document: document,
        customer: customer,
        user: user,
      );
      
      final fileName = '${document.type}_${document.number}_${customer.name.replaceAll(' ', '_')}';
      final filePath = await savePDFToDevice(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );
      
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Please find attached ${document.type.toLowerCase()} ${document.number}',
        subject: '${document.type} ${document.number} from ${user.businessName}',
      );
      
    } catch (e) {
      throw Exception('Failed to share document: $e');
    }
  }

  /// Prints the PDF document (platform specific)
  static Future<void> printDocument({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    try {
      // In a real implementation, you would use the printing package
      // For now, this is a mock implementation
      final pdfBytes = await generateDocumentPDF(
        document: document,
        customer: customer,
        user: user,
      );
      
      // Mock implementation - in reality you would:
      // await Printing.layoutPdf(onLayout: (format) => pdfBytes);
      
      throw UnimplementedError('Print functionality requires printing package integration');
      
    } catch (e) {
      throw Exception('Failed to print document: $e');
    }
  }

  /// Generates a preview of the PDF as HTML (for web preview)
  static Future<String> generatePreviewHTML({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    return _generateHTMLContent(
      document: document,
      customer: customer,
      user: user,
    );
  }
}