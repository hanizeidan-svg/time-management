class Person {
  final int? id;
  final String name;
  final String? color; // Hex color for visual identification

  Person({
    this.id,
    required this.name,
    this.color,
  });

  Person copyWith({
    int? id,
    String? name,
    String? color,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}

class TimeBlock {
  final int? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<ActionItem> actionItems;
  final String category;
  final bool isCompleted;
  final String dayOfWeek;
  final int personId; // New: Link to person

  TimeBlock({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.actionItems,
    required this.category,
    this.isCompleted = false,
    required this.dayOfWeek,
    required this.personId, // Add this parameter
  });

  TimeBlock copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<ActionItem>? actionItems,
    String? category,
    bool? isCompleted,
    String? dayOfWeek,
    int? personId,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actionItems: actionItems ?? this.actionItems,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      personId: personId ?? this.personId,
    );
  }
}

class ActionItem {
  final int? id;
  final String title;
  final bool isCompleted;
  final int timeBlockId;

  ActionItem({
    this.id,
    required this.title,
    this.isCompleted = false,
    required this.timeBlockId,
  });

  ActionItem copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    int? timeBlockId,
  }) {
    return ActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      timeBlockId: timeBlockId ?? this.timeBlockId,
    );
  }
}