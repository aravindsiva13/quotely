// data/models/document.dart
class Document {
  final String id;
  final String type;
  final String number;
  final String customerId;
  final DateTime date;
  final DateTime? dueDate;
  final String status;
  final String currency;
  final String currencySymbol;
  final List<DocumentItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final String? notes;
  final String? terms;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Document({
    required this.id,
    required this.type,
    required this.number,
    required this.customerId,
    required this.date,
    this.dueDate,
    required this.status,
    required this.currency,
    required this.currencySymbol,
    this.items = const [],
    required this.subtotal,
    required this.taxAmount,
    this.discountAmount = 0.0,
    required this.total,
    this.notes,
    this.terms,
    required this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      type: json['type'],
      number: json['number'],
      customerId: json['customer_id'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      dueDate: json['due_date'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['due_date'])
        : null,
      status: json['status'],
      currency: json['currency'],
      currencySymbol: json['currency_symbol'],
      items: json['items'] != null 
        ? (json['items'] as List).map((item) => DocumentItem.fromJson(item)).toList()
        : [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      notes: json['notes'],
      terms: json['terms'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      updatedAt: json['updated_at'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'number': number,
      'customer_id': customerId,
      'date': date.millisecondsSinceEpoch,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'status': status,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total': total,
      'notes': notes,
      'terms': terms,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  Document copyWith({
    String? id,
    String? type,
    String? number,
    String? customerId,
    DateTime? date,
    DateTime? dueDate,
    String? status,
    String? currency,
    String? currencySymbol,
    List<DocumentItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? total,
    String? notes,
    String? terms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      type: type ?? this.type,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DocumentItem {
  final String id;
  final String documentId;
  final String itemId;
  final String name;
  final String description;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final double total;
  final String unit;

  DocumentItem({
    required this.id,
    required this.documentId,
    required this.itemId,
    required this.name,
    this.description = '',
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    this.taxRate = 0.0,
    required this.total,
    this.unit = 'pcs',
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'],
      documentId: json['document_id'],
      itemId: json['item_id'],
      name: json['name'],
      description: json['description'] ?? '',
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document_id': documentId,
      'item_id': itemId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'tax_rate': taxRate,
      'total': total,
      'unit': unit,
    };
  }

  DocumentItem copyWith({
    String? id,
    String? documentId,
    String? itemId,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? discount,
    double? taxRate,
    double? total,
    String? unit,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      total: total ?? this.total,
      unit: unit ?? this.unit,
    );
  }
}