class Expense {
  final String id;
  final String tripId;
  final String category; // 'transport', 'stay', 'activities', 'meals', 'other'
  final double amount;
  final String currency;
  final DateTime? date;
  final String? description;

  Expense({
    required this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    this.date,
    this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      tripId: json['trip_id'],
      category: json['category'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'trip_id': tripId,
      'category': category,
      'amount': amount,
      'currency': currency,
      if (date != null) 'date': date!.toIso8601String().split('T')[0],
      if (description != null) 'description': description,
    };
  }

  Expense copyWith({
    String? id,
    String? tripId,
    String? category,
    double? amount,
    String? currency,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
