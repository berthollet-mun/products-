class Output {
  final String id;
  final String productId;
  final int quantity;
  final String date;
  final String userId;

  Output({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.date,
    required this.userId,
  });

  // Conversion d'une Sortie en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'date': date,
      'user_id': userId,
    };
  }

  // Création d'une Sortie à partir d'une Map
  factory Output.fromMap(Map<String, dynamic> map) {
    return Output(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toInt(),
      date: map['date'] as String,
      userId: map['user_id'] as String,
    );
  }

  // Méthode pour copier une Sortie avec certaines valeurs modifiées
  Output copyWith({
    String? id,
    String? productId,
    int? quantity,
    String? date,
    String? userId,
  }) {
    return Output(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Output{id: $id, productId: $productId, quantity: $quantity, date: $date, userId: $userId}';
  }
}
