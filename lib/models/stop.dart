class Stop {
  final String id;
  final String tripId;
  final String locationName;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final int orderIndex;
  final String? notes;

  Stop({
    required this.id,
    required this.tripId,
    required this.locationName,
    required this.arrivalDate,
    required this.departureDate,
    required this.orderIndex,
    this.notes,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      tripId: json['trip_id'],
      locationName: json['location_name'],
      arrivalDate: DateTime.parse(json['arrival_date']),
      departureDate: DateTime.parse(json['departure_date']),
      orderIndex: json['order_index'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'trip_id': tripId,
      'location_name': locationName,
      'arrival_date': arrivalDate.toIso8601String().split('T')[0],
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'order_index': orderIndex,
      if (notes != null) 'notes': notes,
    };
  }

  Stop copyWith({
    String? id,
    String? tripId,
    String? locationName,
    DateTime? arrivalDate,
    DateTime? departureDate,
    int? orderIndex,
    String? notes,
  }) {
    return Stop(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      locationName: locationName ?? this.locationName,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
    );
  }
}
