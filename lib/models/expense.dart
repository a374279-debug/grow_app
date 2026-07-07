class Expense {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
