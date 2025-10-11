import 'package:flutter/material.dart';

class Todo {
  String id;
  String title;
  String description;
  DateTime dueDate;
  TimeOfDay dueTime;
  bool isCompleted;
  DateTime createdAt;
  int? notificationId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    this.isCompleted = false,
    required this.createdAt,
    this.notificationId,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTimeHour': dueTime.hour,
      'dueTimeMinute': dueTime.minute,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  // Create from JSON
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      dueTime: TimeOfDay(
        hour: json['dueTimeHour'] ?? 9,
        minute: json['dueTimeMinute'] ?? 0,
      ),
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      notificationId: json['notificationId'],
    );
  }

  // Get combined DateTime with time
  DateTime get dueDateTimeComplete {
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );
  }

  // Get minutes until due
  int get minutesUntilDue {
    return dueDateTimeComplete.difference(DateTime.now()).inMinutes;
  }

  // Get hours until due
  int get hoursUntilDue {
    return dueDateTimeComplete.difference(DateTime.now()).inHours;
  }

  // Get days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Check if overdue
  bool get isOverdue {
    return minutesUntilDue < 0 && !isCompleted;
  }

  // Check if due soon (within 24 hours)
  bool get isDueSoon {
    return hoursUntilDue <= 24 && hoursUntilDue >= 0 && !isCompleted;
  }

  // Check if due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day &&
        !isCompleted;
  }

  // Copy with
  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isCompleted,
    int? notificationId,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}