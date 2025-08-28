
// data/models/item.dart
class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final double taxRate;
  final String unit;
  final String? category;
  final String? imagePath;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.taxRate = 0.0,
    this.unit = 'pcs',
    this.category,
    this.imagePath,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      category: json['category'],
      imagePath: json['image_path'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'tax_rate': taxRate,
      'unit': unit,
      'category': category,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Item copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? taxRate,
    String? unit,
    String? category,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      taxRate: taxRate ?? this.taxRate,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}