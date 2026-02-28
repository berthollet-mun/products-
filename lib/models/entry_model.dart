class Entry {
  final String id;
  final String productId;
  final int quantity;
  final String date;
  final String userId;

  Entry({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.date,
    required this.userId,
  });

  // Conversion d'une Entrée en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'date': date,
      'user_id': userId,
    };
  }

  // Création d'une Entrée à partir d'une Map
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toInt(),
      date: map['date'] as String,
      userId: map['user_id'] as String,
    );
  }

  // Méthode pour copier une Entrée avec certaines valeurs modifiées
  Entry copyWith({
    String? id,
    String? productId,
    int? quantity,
    String? date,
    String? userId,
  }) {
    return Entry(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Entry{id: $id, productId: $productId, quantity: $quantity, date: $date, userId: $userId}';
  }
}
