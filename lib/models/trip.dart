class Trip {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? coverPhotoUrl;
  final bool isPublic;
  final double budget;
  final DateTime? createdAt;

  Trip({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.coverPhotoUrl,
    this.isPublic = false,
    this.budget = 0.0,
    this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      coverPhotoUrl: json['cover_photo_url'],
      isPublic: json['is_public'] ?? false,
      budget: (json['budget'] ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      if (description != null) 'description': description,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
      'is_public': isPublic,
      'budget': budget,
    };
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? coverPhotoUrl,
    bool? isPublic,
    double? budget,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      isPublic: isPublic ?? this.isPublic,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
