import 'package:intl/intl.dart';

class Sale {
  String id;
  DateTime date;
  String total;

  Sale({required this.id, required this.date, required this.total});

  // Conversion d'un Sale en Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date.toIso8601String(), 'total': total};
  }

  // creation d'un Sale  a partir d'une Map
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      date: DateTime.parse(map['date']),
      total: map['total'],
    );
  }

  // Methode pour copier un Sale avec les valeurs mofifiees
  Sale copyWith({String? id, DateTime? date, String? total}) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      total: total ?? this.total,
    );
  }

  // formate la date d'echenace pour l'affichage
  String get formattedDate {
    return DateFormat('dd/MM/yyy').format(date);
  }

  // bool
  @override
  String toString() {
    return 'Sale{id: $id, date: $date, total: $total}';
  }
}
