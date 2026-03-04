class Product {
  final String id;
  final String sku;
  final String name;
  final double price;
  final int quantity;
  final int stockMinimum;
  final String createdAt;
  final String? description;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.quantity,
    this.stockMinimum = 5,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'price': price,
      'quantity': quantity,
      'stock_minimum': stockMinimum,
      'created_at': createdAt,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      sku: map['sku'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      stockMinimum: ((map['stock_minimum'] ?? 5) as num).toInt(),
      createdAt:
          (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      description: map['description'] as String?,
    );
  }

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    double? price,
    int? quantity,
    int? stockMinimum,
    String? createdAt,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      stockMinimum: stockMinimum ?? this.stockMinimum,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, sku: $sku, name: $name, price: $price, quantity: $quantity, stockMinimum: $stockMinimum, createdAt: $createdAt}';
  }
}
