// Модель задачи с расширенными полями для Adaptive Energy System

enum Phase { morning, day, evening }

enum Priority { P0, P1, P2 }

enum Tag { isMechanical, isEssential, isDeepWork, isGrowth }

class Task {
  final String id;
  final String title;
  final Phase phase;
  final Priority priority;
  final int energyCost; // базовый расход в %
  final List<Tag> tags;
  final String? hint;
  final int? timerMinutes;
  bool isCompleted;
  final bool isCustom;

  Task({
    required this.id,
    required this.title,
    required this.phase,
    required this.priority,
    required this.energyCost,
    required this.tags,
    this.hint,
    this.timerMinutes,
    this.isCompleted = false,
    this.isCustom = false,
  });

  // Конструктор из JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      phase: Phase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => Phase.day,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.P1,
      ),
      energyCost: json['energyCost'] as int? ?? 15,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => Tag.values.firstWhere(
                    (e) => e.name == tag,
                    orElse: () => Tag.isEssential,
                  ))
              .toList() ??
          [],
      hint: json['hint'] as String?,
      timerMinutes: json['timerMinutes'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'phase': phase.name,
      'priority': priority.name,
      'energyCost': energyCost,
      'tags': tags.map((tag) => tag.name).toList(),
      'hint': hint,
      'timerMinutes': timerMinutes,
      'isCompleted': isCompleted,
      'isCustom': isCustom,
    };
  }

  // Копирование с изменениями
  Task copyWith({
    String? id,
    String? title,
    Phase? phase,
    Priority? priority,
    int? energyCost,
    List<Tag>? tags,
    String? hint,
    int? timerMinutes,
    bool? isCompleted,
    bool? isCustom,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      phase: phase ?? this.phase,
      priority: priority ?? this.priority,
      energyCost: energyCost ?? this.energyCost,
      tags: tags ?? this.tags,
      hint: hint ?? this.hint,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
