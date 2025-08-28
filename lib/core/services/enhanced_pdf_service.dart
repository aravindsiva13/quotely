// lib/core/services/enhanced_pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import '../../data/models/document.dart';
import '../../data/models/customer.dart';
import '../../data/models/user.dart';

class EnhancedPDFService {
  static const String _fontFamily = 'Roboto';
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.ImageProvider? _logoImage;

  /// Initialize PDF service with fonts and assets
  static Future<void> initialize() async {
    try {
      // Load fonts
      _regularFont = await PdfGoogleFonts.robotoRegular();
      _boldFont = await PdfGoogleFonts.robotoBold();
      
      // Try to load logo if available
      try {
        final logoData = await rootBundle.load('assets/images/logo.png');
        _logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (e) {
        // Logo not found, continue without it
        print('Logo not found, continuing without logo: $e');
      }
      
      print('✅ PDF Service initialized');
    } catch (e) {
      print('❌ Error initializing PDF service: $e');
      rethrow;
    }
  }

  /// Generate a professional PDF document
  static Future<Uint8List> generateDocumentPDF({
    required Document document,
    required Customer customer,
    required User user,
    bool includeWatermark = false,
  }) async {
    final pdf = pw.Document(
      title: '${document.type} ${document.number}',
      author: user.businessName,
      creator: 'Quotation Maker App',
      subject: '${document.type} for ${customer.name}',
    );

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(document, user),
          pw.SizedBox(height: 20),
          _buildCompanyCustomerInfo(user, customer),
          pw.SizedBox(height: 20),
          _buildDocumentInfo(document),
          pw.SizedBox(height: 20),
          _buildItemsTable(document),
          pw.SizedBox(height: 20),
          _buildSummary(document),
          pw.SizedBox(height: 20),
          _buildNotesAndTerms(document),
          pw.Spacer(),
          _buildFooter(user),
        ],
        header: includeWatermark ? (context) => _buildWatermark() : null,
        footer: (context) => _buildPageFooter(context),
      ),
    );

    return pdf.save();
  }

  /// Generate and save PDF to device
  static Future<String> savePDFToDevice({
    required Document document,
    required Customer customer,
    required User user,
    String? customFileName,
  }) async {
    try {
      final pdfBytes = await generateDocumentPDF(
        document: document,
        customer: customer,
        user: user,
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = customFileName ?? 
        '${document.type}_${document.number}_${customer.name.replaceAll(' ', '_')}.pdf';
      
      final file = File('${directory.path}/pdfs/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(pdfBytes);

      print('✅ PDF saved: ${file.path}');
      return file.path;
    } catch (e) {
      print('❌ Error saving PDF: $e');
      rethrow;
    }
  }

  /// Share PDF document
  static Future<void> shareDocument({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    try {
      final filePath = await savePDFToDevice(
        document: document,
        customer: customer,
        user: user,
      );

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Please find attached ${document.type.toLowerCase()} ${document.number}',
        subject: '${document.type} ${document.number} from ${user.businessName}',
      );
    } catch (e) {
      print('❌ Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Print PDF document
  static Future<void> printDocument({
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

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${document.type} ${document.number}',
      );
    } catch (e) {
      print('❌ Error printing PDF: $e');
      rethrow;
    }
  }

  /// Generate PDF preview
  static Future<Uint8List> generatePreviewPDF({
    required Document document,
    required Customer customer,
    required User user,
  }) async {
    return generateDocumentPDF(
      document: document,
      customer: customer,
      user: user,
      includeWatermark: true,
    );
  }

  // ==================== PRIVATE HELPER METHODS ====================

  static pw.Widget _buildHeader(Document document, User user) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo and company name
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (_logoImage != null) ...[
                pw.Image(_logoImage!, height: 60, width: 60),
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                user.businessName,
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 24,
                  color: PdfColors.blue800,
                ),
              ),
            ],
          ),
        ),
        
        // Document title and info
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                document.type.toUpperCase(),
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 28,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                document.number,
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 16,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildStatusBadge(document.status),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatusBadge(String status) {
    PdfColor badgeColor;
    switch (status.toLowerCase()) {
      case 'paid':
        badgeColor = PdfColors.green;
        break;
      case 'overdue':
        badgeColor = PdfColors.red;
        break;
      case 'pending':
      case 'sent':
        badgeColor = PdfColors.orange;
        break;
      default:
        badgeColor = PdfColors.grey;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: badgeColor.shade100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: badgeColor),
      ),
      child: pw.Text(
        status.toUpperCase(),
        style: pw.TextStyle(
          font: _boldFont,
          fontSize: 10,
          color: badgeColor,
        ),
      ),
    );
  }

  static pw.Widget _buildCompanyCustomerInfo(User user, Customer customer) {
    final businessInfo = user.settings.businessInfo;
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // From (Company)
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FROM',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 12,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                businessInfo.name.isNotEmpty ? businessInfo.name : user.businessName,
                style: pw.TextStyle(font: _boldFont, fontSize: 14),
              ),
              if (businessInfo.address.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(businessInfo.address, style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (businessInfo.city.isNotEmpty) ...[
                pw.Text(
                  '${businessInfo.city}, ${businessInfo.state} ${businessInfo.zipCode}',
                  style: pw.TextStyle(font: _regularFont, fontSize: 10),
                ),
              ],
              if (businessInfo.country.isNotEmpty) ...[
                pw.Text(businessInfo.country, style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (businessInfo.phone.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Tel: ${businessInfo.phone}', style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (businessInfo.email.isNotEmpty) ...[
                pw.Text('Email: ${businessInfo.email}', style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
            ],
          ),
        ),
        
        pw.SizedBox(width: 40),
        
        // To (Customer)
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'TO',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 12,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                customer.name,
                style: pw.TextStyle(font: _boldFont, fontSize: 14),
              ),
              if (customer.address.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(customer.address, style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (customer.city.isNotEmpty) ...[
                pw.Text(
                  '${customer.city}, ${customer.state} ${customer.zipCode}',
                  style: pw.TextStyle(font: _regularFont, fontSize: 10),
                ),
              ],
              if (customer.country.isNotEmpty) ...[
                pw.Text(customer.country, style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (customer.phone.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Tel: ${customer.phone}', style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
              if (customer.email.isNotEmpty) ...[
                pw.Text('Email: ${customer.email}', style: pw.TextStyle(font: _regularFont, fontSize: 10)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDocumentInfo(Document document) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            '${document.type} Date',
            AppDateUtils.formatDate(document.date),
          ),
          if (document.dueDate != null)
            _buildInfoItem(
              'Due Date',
              AppDateUtils.formatDate(document.dueDate!),
            ),
          _buildInfoItem(
            'Status',
            document.status,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: _boldFont,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Document document) {
    return pw.Column(
      children: [
        // Table header
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue50,
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blue200),
            ),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  'DESCRIPTION',
                  style: pw.TextStyle(font: _boldFont, fontSize: 10),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'QTY',
                  style: pw.TextStyle(font: _boldFont, fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'RATE',
                  style: pw.TextStyle(font: _boldFont, fontSize: 10),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'AMOUNT',
                  style: pw.TextStyle(font: _boldFont, fontSize: 10),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Table rows
        ...document.items.map((item) => _buildItemRow(item, document.currencySymbol)),
      ],
    );
  }

  static pw.Widget _buildItemRow(DocumentItem item, String currencySymbol) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.name,
                  style: pw.TextStyle(font: _boldFont, fontSize: 11),
                ),
                if (item.description.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    item.description,
                    style: pw.TextStyle(
                      font: _regularFont,
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              '${item.quantity} ${item.unit}',
              style: pw.TextStyle(font: _regularFont, fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              CurrencyUtils.formatAmount(item.unitPrice, currencySymbol),
              style: pw.TextStyle(font: _regularFont, fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              CurrencyUtils.formatAmount(item.total, currencySymbol),
              style: pw.TextStyle(font: _boldFont, fontSize: 10),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummary(Document document) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Container()),
        pw.Container(
          width: 250,
          child: pw.Column(
            children: [
              _buildSummaryRow(
                'Subtotal',
                CurrencyUtils.formatAmount(document.subtotal, document.currencySymbol),
              ),
              if (document.discountAmount > 0)
                _buildSummaryRow(
                  'Discount',
                  '- ${CurrencyUtils.formatAmount(document.discountAmount, document.currencySymbol)}',
                ),
              _buildSummaryRow(
                'Tax',
                CurrencyUtils.formatAmount(document.taxAmount, document.currencySymbol),
              ),
              pw.Container(
                height: 1,
                color: PdfColors.grey400,
                margin: const pw.EdgeInsets.symmetric(vertical: 8),
              ),
              _buildSummaryRow(
                'TOTAL',
                CurrencyUtils.formatAmount(document.total, document.currencySymbol),
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: isTotal ? _boldFont : _regularFont,
              fontSize: isTotal ? 14 : 11,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              font: isTotal ? _boldFont : _regularFont,
              fontSize: isTotal ? 14 : 11,
              color: isTotal ? PdfColors.blue800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildNotesAndTerms(Document document) {
    if ((document.notes?.isEmpty ?? true) && (document.terms?.isEmpty ?? true)) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (document.notes?.isNotEmpty ?? false) ...[
          pw.Text(
            'NOTES',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Text(
              document.notes!,
              style: pw.TextStyle(font: _regularFont, fontSize: 10),
            ),
          ),
          pw.SizedBox(height: 16),
        ],
        
        if (document.terms?.isNotEmpty ?? false) ...[
          pw.Text(
            'TERMS & CONDITIONS',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Text(
              document.terms!,
              style: pw.TextStyle(font: _regularFont, fontSize: 10),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildFooter(User user) {
    final businessInfo = user.settings.businessInfo;
    
    return pw.Column(
      children: [
        pw.Container(
          height: 1,
          color: PdfColors.grey300,
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'Generated by Quotation Maker • ${AppDateUtils.formatDateTime(DateTime.now())}',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        if (businessInfo.taxId.isNotEmpty || businessInfo.registrationNumber.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (businessInfo.taxId.isNotEmpty) ...[
                pw.Text(
                  'Tax ID: ${businessInfo.taxId}',
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                if (businessInfo.registrationNumber.isNotEmpty)
                  pw.Text(' • ', style: pw.TextStyle(font: _regularFont, fontSize: 8)),
              ],
              if (businessInfo.registrationNumber.isNotEmpty) ...[
                pw.Text(
                  'Reg. No: ${businessInfo.registrationNumber}',
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildWatermark() {
    return pw.Positioned(
      top: 200,
      left: 100,
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Text(
          'PREVIEW',
          style: pw.TextStyle(
            font: _boldFont,
            fontSize: 72,
            color: PdfColors.grey200,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          AppDateUtils.formatDate(DateTime.now()),
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  // ==================== BATCH OPERATIONS ====================

  /// Generate multiple PDFs for batch export
  static Future<List<String>> generateBatchPDFs({
    required List<Document> documents,
    required Map<String, Customer> customers,
    required User user,
    String? directory,
  }) async {
    final List<String> generatedFiles = [];
    
    try {
      for (final document in documents) {
        final customer = customers[document.customerId];
        if (customer != null) {
          final filePath = await savePDFToDevice(
            document: document,
            customer: customer,
            user: user,
          );
          generatedFiles.add(filePath);
        }
      }
      
      print('✅ Generated ${generatedFiles.length} PDF files');
      return generatedFiles;
    } catch (e) {
      print('❌ Error generating batch PDFs: $e');
      rethrow;
    }
  }

  /// Get PDF file size
  static Future<int> getPDFFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      print('❌ Error getting PDF file size: $e');
      return 0;
    }
  }

  /// Clean up old PDF files
  static Future<void> cleanupOldPDFs({int daysOld = 30}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/pdfs');
      
      if (await pdfDir.exists()) {
        final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
        
        await for (final entity in pdfDir.list()) {
          if (entity is File && entity.path.endsWith('.pdf')) {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
              print('🗑️ Deleted old PDF: ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error cleaning up old PDFs: $e');
    }
  }
}