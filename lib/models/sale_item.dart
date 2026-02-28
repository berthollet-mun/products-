class SaleItem {
  String id;
  String saleId;
  String productId;
  String qty;
  String price;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.qty,
    required this.price,
  });

  // Conversion d'un Sale_item en Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'saleId': saleId, 'productId': productId, 'price': price};
  }

  // creation d'un Sale_item en Map
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      qty: map['qty'],
      price: map['price'],
    );
  }

  // Methode pour copier un Sale_item avec les valeurs modifiees
  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? qty,
    String? price,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'SaleItem{id: $id, saleId: $saleId, product: $productId, qty: $qty, price: $price}';
  }
}
