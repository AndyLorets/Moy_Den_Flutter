import 'dart:convert';

// Профиль пользователя — набор кастомных задач + имя
class Profile {
  final String id;
  String name;
  // Кастомные задачи сохранены как JSON-строки по фазе
  final Map<String, List<Map<String, dynamic>>> customTasks;

  Profile({
    required this.id,
    required this.name,
    Map<String, List<Map<String, dynamic>>>? customTasks,
  }) : customTasks = customTasks ??
            {'morning': [], 'day': [], 'evening': []};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'customTasks': customTasks,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        name: json['name'] as String,
        customTasks: {
          'morning': _parseTaskList(json['customTasks']?['morning']),
          'day':     _parseTaskList(json['customTasks']?['day']),
          'evening': _parseTaskList(json['customTasks']?['evening']),
        },
      );

  static List<Map<String, dynamic>> _parseTaskList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List).cast<Map<String, dynamic>>();
  }

  static List<Profile> decodeList(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => Profile.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<Profile> profiles) =>
      jsonEncode(profiles.map((p) => p.toJson()).toList());
}
