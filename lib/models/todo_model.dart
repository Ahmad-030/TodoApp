class Todo {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  DateTime createdAt;
  int? notificationId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.notificationId,
  });

  // Convert to JSON
  Map toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
    };
  }

  // Create from JSON
  factory Todo.fromJson(Map json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      notificationId: json['notificationId'],
    );
  }

  // Get days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Check if overdue
  bool get isOverdue {
    return daysUntilDue < 0 && !isCompleted;
  }

  // Check if due soon (within 1 day)
  bool get isDueSoon {
    return daysUntilDue <= 1 && daysUntilDue >= 0 && !isCompleted;
  }

  // Copy with
  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    int? notificationId,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}