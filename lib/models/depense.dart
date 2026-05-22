extension DateFormatting on DateTime {
  String get ymd => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class Depense {
  final String id;
  final double montant;
  final String categorie;
  final DateTime date;

  Depense({
    required this.id,
    required this.montant,
    required this.categorie,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'categorie': categorie,
      'date': date.toIso8601String(),
    };
  }

  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'],
      montant: (map['montant'] as num).toDouble(),
      categorie: map['categorie'],
      date: DateTime.parse(map['date']),
    );
  }
}