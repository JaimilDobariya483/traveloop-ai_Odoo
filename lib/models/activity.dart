import 'package:flutter/material.dart';

class TripActivity {
  final String id;
  final String stopId;
  final String title;
  final String? description;
  final DateTime? activityDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final double? cost;
  final String? bookingReference;

  TripActivity({
    required this.id,
    required this.stopId,
    required this.title,
    this.description,
    this.activityDate,
    this.startTime,
    this.endTime,
    this.cost,
    this.bookingReference,
  });

  factory TripActivity.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      return null;
    }

    return TripActivity(
      id: json['id'],
      stopId: json['stop_id'],
      title: json['title'],
      description: json['description'],
      activityDate: json['activity_date'] != null
          ? DateTime.parse(json['activity_date'])
          : null,
      startTime: parseTime(json['start_time']),
      endTime: parseTime(json['end_time']),
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      bookingReference: json['booking_reference'],
    );
  }

  Map<String, dynamic> toJson() {
    String? formatTime(TimeOfDay? time) {
      if (time == null) return null;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00';
    }

    return {
      if (id.isNotEmpty) 'id': id,
      'stop_id': stopId,
      'title': title,
      if (description != null) 'description': description,
      if (activityDate != null)
        'activity_date': activityDate!.toIso8601String().split('T')[0],
      if (startTime != null) 'start_time': formatTime(startTime),
      if (endTime != null) 'end_time': formatTime(endTime),
      if (cost != null) 'cost': cost,
      if (bookingReference != null) 'booking_reference': bookingReference,
    };
  }

  TripActivity copyWith({
    String? id,
    String? stopId,
    String? title,
    String? description,
    DateTime? activityDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    String? bookingReference,
  }) {
    return TripActivity(
      id: id ?? this.id,
      stopId: stopId ?? this.stopId,
      title: title ?? this.title,
      description: description ?? this.description,
      activityDate: activityDate ?? this.activityDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      bookingReference: bookingReference ?? this.bookingReference,
    );
  }
}
