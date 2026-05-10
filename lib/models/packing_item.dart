class PackingItem {
  final String id;
  final String tripId;
  final String category; // 'Clothing', 'Documents', 'Electronics'
  final String itemName;
  final bool isPacked;

  PackingItem({
    required this.id,
    required this.tripId,
    required this.category,
    required this.itemName,
    this.isPacked = false,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'],
      tripId: json['trip_id'],
      category: json['category'],
      itemName: json['item_name'],
      isPacked: json['is_packed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'trip_id': tripId,
      'category': category,
      'item_name': itemName,
      'is_packed': isPacked,
    };
  }

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? category,
    String? itemName,
    bool? isPacked,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      isPacked: isPacked ?? this.isPacked,
    );
  }
}
