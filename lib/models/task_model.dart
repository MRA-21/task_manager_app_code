import 'dart:convert';

/// Defines the urgency levels for tasks within the application.
enum TaskPriority {
  low,
  medium,
  high,
}

/// A highly structured, immutable data model representing a single user task.
/// 
/// Designed for local persistence via JSON serialization.
class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final String category;
  final bool isCompleted;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
  });

  /// Creates a deep copy of the [TaskModel] with overriding values.
  /// 
  /// Useful for state mutation within the state management layer.
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    String? category,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Converts a standard Map structure back into a [TaskModel] instance.
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: map['category'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  /// Converts the [TaskModel] instance into a serializable Map structure.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString(),
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  /// Factory method to parse a raw JSON string directly into a [TaskModel].
  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Encodes the [TaskModel] directly into a JSON string for storage.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.category == category &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dueDate.hashCode ^
        priority.hashCode ^
        category.hashCode ^
        isCompleted.hashCode;
  }
}