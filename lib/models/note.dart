class TripNote {
  final String id;
  final String tripId;
  final String? title;
  final String content;
  final DateTime? createdAt;

  TripNote({
    required this.id,
    required this.tripId,
    this.title,
    required this.content,
    this.createdAt,
  });

  factory TripNote.fromJson(Map<String, dynamic> json) {
    return TripNote(
      id: json['id'],
      tripId: json['trip_id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'trip_id': tripId,
      if (title != null) 'title': title,
      'content': content,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  TripNote copyWith({
    String? id,
    String? tripId,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return TripNote(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
