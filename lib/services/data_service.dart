import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/keys.dart';
import '../constants/strings.dart';
import '../models/task.dart';

// Модель блока расписания
class ScheduleItem {
  final String id;
  String time;
  String label;

  ScheduleItem({required this.id, required this.time, required this.label});

  Map<String, dynamic> toJson() => {'id': id, 'time': time, 'label': label};

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] as String,
        time: json['time'] as String,
        label: json['label'] as String,
      );
}

// Тип учёбы (чередуется каждый день)
enum StudyType { english, unity, ai }

extension StudyTypeExt on StudyType {
  String get label {
    switch (this) {
      case StudyType.english:
        return 'Английский';
      case StudyType.unity:
        return 'Unity';
      case StudyType.ai:
        return 'ИИ / Claude';
    }
  }

  String get taskId {
    switch (this) {
      case StudyType.english:
        return 'm_study_0';
      case StudyType.unity:
        return 'm_study_1';
      case StudyType.ai:
        return 'm_study_2';
    }
  }

  String get tipKey {
    switch (this) {
      case StudyType.english:
        return 'eng';
      case StudyType.unity:
        return 'unity';
      case StudyType.ai:
        return 'ai';
    }
  }
}

// Центральный сервис данных
class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  DataService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'DataService.init() не был вызван');
    return _prefs!;
  }

  // ── Учёба — чередование ──────────────────────────────────
  StudyType get todayStudy {
    final epochStr = _p.getString(PrefKeys.epoch) ?? '';
    DateTime epoch;
    if (epochStr.isEmpty) {
      epoch = DateTime.now();
      _p.setString(PrefKeys.epoch, epoch.toIso8601String());
    } else {
      epoch = DateTime.tryParse(epochStr) ?? DateTime.now();
    }
    final diff = DateTime.now().difference(epoch).inDays;
    final idx = ((diff % 3) + 3) % 3;
    return StudyType.values[idx];
  }

  // ── Задачи (фиксированные) ───────────────────────────────
  List<Task> get morningTasks {
    final study = todayStudy;
    return [
      Task(
        id: 'm_pose',
        title: TaskTexts.pose,
        phase: Phase.morning,
        priority: Priority.P0,
        energyCost: 5,
        tags: [Tag.isMechanical, Tag.isEssential],
        hint: Tips.all['pose']?['body'],
      ),
      Task(
        id: 'm_breath',
        title: TaskTexts.breath,
        phase: Phase.morning,
        priority: Priority.P0,
        energyCost: 5,
        tags: [Tag.isMechanical, Tag.isEssential],
        hint: Tips.all['breath']?['body'],
      ),
      Task(
        id: 'm_vis',
        title: TaskTexts.visualization,
        phase: Phase.morning,
        priority: Priority.P1,
        energyCost: 10,
        tags: [Tag.isMechanical],
        hint: Tips.all['m1']?['body'],
      ),
      Task(
        id: 'm_affirm',
        title: TaskTexts.affirmation,
        phase: Phase.morning,
        priority: Priority.P1,
        energyCost: 5,
        tags: [Tag.isMechanical],
        hint: Tips.all['m2']?['body'],
      ),
      Task(
        id: study.taskId,
        title: switch (study) {
          StudyType.english => TaskTexts.studyEnglish,
          StudyType.unity => TaskTexts.studyUnity,
          StudyType.ai => TaskTexts.studyAI,
        },
        phase: Phase.morning,
        priority: Priority.P1,
        energyCost: 20,
        tags: [Tag.isDeepWork],
        timerMinutes: 10,
        hint: Tips.all[study.tipKey]?['body'],
      ),
    ];
  }

  List<Task> get dayTasks => [
        Task(
          id: 'd_action',
          title: TaskTexts.jobAction,
          phase: Phase.day,
          priority: Priority.P0,
          energyCost: 15,
          tags: [Tag.isEssential],
          hint: Tips.all['d1']?['body'],
        ),
        Task(
          id: 'd_wild',
          title: TaskTexts.wildCard,
          phase: Phase.day,
          priority: Priority.P2,
          energyCost: 20,
          tags: [Tag.isGrowth],
          hint: Tips.all['d2']?['body'],
        ),
        Task(
          id: 'd_game',
          title: TaskTexts.ownGame,
          phase: Phase.day,
          priority: Priority.P1,
          energyCost: 25,
          tags: [Tag.isDeepWork, Tag.isGrowth],
          timerMinutes: 10,
          hint: Tips.all['d3']?['body'],
        ),
      ];

  List<Task> get eveningTasks => [
        Task(
          id: 'e_log',
          title: TaskTexts.dayLog,
          phase: Phase.evening,
          priority: Priority.P1,
          energyCost: 10,
          tags: [Tag.isMechanical],
        ),
        Task(
          id: 'e_shadow',
          title: TaskTexts.shadowDebug,
          phase: Phase.evening,
          priority: Priority.P1,
          energyCost: 15,
          tags: [],
          hint: Tips.all['e2']?['body'],
        ),
        Task(
          id: 'e_let',
          title: TaskTexts.letGo,
          phase: Phase.evening,
          priority: Priority.P2,
          energyCost: 5,
          tags: [Tag.isMechanical],
          hint: Tips.all['e3']?['body'],
        ),
      ];

  // Бонусная задача для состояния "Воодушевление"
  Task get bonusTask => Task(
        id: 'bonus_energy',
        title: 'Бонус: напиши одному человеку из индустрии — просто поздоровайся',
        phase: Phase.day,
        priority: Priority.P2,
        energyCost: 15,
        tags: [Tag.isGrowth],
      );

  // Все фиксированные задачи (без кастомных и бонусной)
  List<Task> get allFixedTasks => [
        ...morningTasks,
        ...dayTasks,
        ...eveningTasks,
      ];

  // ── Кастомные задачи ────────────────────────────────────
  List<Task> getCustomTasks(String phase) {
    final key = 'cu_$phase';
    final json = _p.getString(key) ?? '[]';
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) {
        // Поддержка старого формата {id, text} и нового {Task.toJson()}
        if (e.containsKey('text') && !e.containsKey('title')) {
          final phaseEnum = switch (phase) {
            'morning' => Phase.morning,
            'day' => Phase.day,
            _ => Phase.evening,
          };
          return Task(
            id: e['id'] as String,
            title: e['text'] as String,
            phase: phaseEnum,
            priority: Priority.P1,
            energyCost: 15,
            tags: [],
            isCustom: true,
          );
        }
        return Task.fromJson(e as Map<String, dynamic>);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  void saveCustomTask(Task task) {
    final phase = task.phase.name;
    final key = 'cu_$phase';
    final tasks = getCustomTasks(phase);
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      tasks[idx] = task;
    } else {
      tasks.add(task);
    }
    _p.setString(key, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // Оставляем для совместимости — создаёт простую задачу только с текстом
  void addCustomTask(String phase, String text) {
    final phaseEnum = switch (phase) {
      'morning' => Phase.morning,
      'day' => Phase.day,
      _ => Phase.evening,
    };
    saveCustomTask(Task(
      id: 'cu_${DateTime.now().millisecondsSinceEpoch}',
      title: text,
      phase: phaseEnum,
      priority: Priority.P1,
      energyCost: 15,
      tags: [],
      isCustom: true,
    ));
  }

  void removeCustomTask(String phase, String id) {
    final key = 'cu_$phase';
    final tasks = getCustomTasks(phase).where((t) => t.id != id).toList();
    _p.setString(key, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // ── Выполнение задач ────────────────────────────────────
  bool isTaskDone(String id) => _p.getBool(PrefKeys.taskPrefix + id) ?? false;

  void setTaskDone(String id, bool value) {
    _p.setBool(PrefKeys.taskPrefix + id, value);
  }

  void toggleTask(String id) {
    final key = PrefKeys.taskPrefix + id;
    _p.setBool(key, !(_p.getBool(key) ?? false));
    _checkStreakCompletion();
  }

  // ── Прогресс ────────────────────────────────────────────
  List<String> get allTaskIds {
    final ids = <String>[];
    for (final t in allFixedTasks) { ids.add(t.id); }
    for (final t in getCustomTasks('morning')) { ids.add(t.id); }
    for (final t in getCustomTasks('day')) { ids.add(t.id); }
    for (final t in getCustomTasks('evening')) { ids.add(t.id); }
    return ids;
  }

  int get completedCount => allTaskIds.where(isTaskDone).length;
  int get totalCount => allTaskIds.length;

  // ── Стрик — только по P0 ────────────────────────────────
  int get streak => _p.getInt(PrefKeys.streak) ?? 0;

  void _checkStreakCompletion() {
    // Стрик засчитывается только если все P0-задачи выполнены
    final p0Tasks = allFixedTasks.where((t) => t.priority == Priority.P0).toList();
    if (p0Tasks.isEmpty) return;
    final allP0Done = p0Tasks.every((t) => isTaskDone(t.id));
    if (allP0Done) {
      final today = _todayKey();
      if (_p.getString(PrefKeys.lastDay) != today) {
        _p.setString(PrefKeys.lastDay, today);
        _p.setInt(PrefKeys.streak, streak + 1);
      }
    }
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  // Вернёт true если вчера стрик был сломан (lastDay не вчера и стрик был > 0)
  bool get wasStreakBrokenToday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    final lastDay = _p.getString(PrefKeys.lastDay) ?? '';
    // Если последний зачёт был позавчера или раньше — стрик сброшен
    return streak == 0 && lastDay.isNotEmpty && lastDay != yesterdayKey && lastDay != _todayKey();
  }

  // ── Поля состояния ──────────────────────────────────────
  String get morningState => _p.getString(PrefKeys.state) ?? '';
  set morningState(String v) => _p.setString(PrefKeys.state, v);

  String get conflict => _p.getString(PrefKeys.conflict) ?? '';
  set conflict(String v) => _p.setString(PrefKeys.conflict, v);

  String get motiv => _p.getString(PrefKeys.motiv) ?? '';
  set motiv(String v) => _p.setString(PrefKeys.motiv, v);

  String get fear => _p.getString(PrefKeys.fear) ?? '';
  set fear(String v) => _p.setString(PrefKeys.fear, v);

  String get insight => _p.getString(PrefKeys.insight) ?? '';
  set insight(String v) => _p.setString(PrefKeys.insight, v);

  String get smysl => _p.getString(PrefKeys.smysl) ?? '';
  set smysl(String v) => _p.setString(PrefKeys.smysl, v);

  // ── GitHub Gist токен ───────────────────────────────────
  String get ghToken => _p.getString(PrefKeys.ghToken) ?? '';
  set ghToken(String v) => _p.setString(PrefKeys.ghToken, v);

  bool get autosync => _p.getBool(PrefKeys.autosync) ?? false;
  set autosync(bool v) => _p.setBool(PrefKeys.autosync, v);

  // ── Расписание ──────────────────────────────────────────
  List<ScheduleItem> get schedule {
    final json = _p.getString(PrefKeys.schedule);
    if (json == null) return _defaultSchedule();
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _defaultSchedule();
    }
  }

  void saveSchedule(List<ScheduleItem> items) {
    _p.setString(
        PrefKeys.schedule, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  List<ScheduleItem> _defaultSchedule() => DefaultSchedule.items
      .map((e) =>
          ScheduleItem(id: e['id']!, time: e['time']!, label: e['label']!))
      .toList();

  void resetSchedule() => _p.remove(PrefKeys.schedule);

  // ── Smart Entry — показывать ли экран входа сегодня ────
  bool get shouldShowEntry {
    final last = _p.getString(PrefKeys.lastEntryDay) ?? '';
    return last != _todayKey();
  }

  void markEntryShown() => _p.setString(PrefKeys.lastEntryDay, _todayKey());

  // ── Сброс дня ───────────────────────────────────────────
  void resetDay() {
    final keep = <String, dynamic>{};
    final keepKeys = [
      PrefKeys.streak,
      PrefKeys.lastDay,
      PrefKeys.smysl,
      PrefKeys.epoch,
      PrefKeys.schedule,
      'cu_morning',
      'cu_day',
      'cu_evening',
      PrefKeys.autosync,
      PrefKeys.ghToken,
    ];
    for (final k in keepKeys) {
      final v = _p.get(k);
      if (v != null) keep[k] = v;
    }
    _p.clear();
    for (final e in keep.entries) {
      if (e.value is bool) {
        _p.setBool(e.key, e.value as bool);
      } else if (e.value is int) {
        _p.setInt(e.key, e.value as int);
      } else if (e.value is double) {
        _p.setDouble(e.key, e.value as double);
      } else if (e.value is String) {
        _p.setString(e.key, e.value as String);
      }
    }
  }

  // ── Прямой доступ к prefs (для ProfileService) ──────────────
  void setRawPref(String key, String value) => _p.setString(key, value);

  // ── Экспорт/импорт для Gist ─────────────────────────────
  Map<String, dynamic> exportData() {
    final keys = _p.getKeys();
    final data = <String, dynamic>{};
    for (final k in keys) {
      if (k == PrefKeys.ghToken) continue;
      data[k] = _p.get(k);
    }
    return data;
  }

  void importData(Map<String, dynamic> data) {
    for (final e in data.entries) {
      if (e.value is bool) {
        _p.setBool(e.key, e.value as bool);
      } else if (e.value is int) {
        _p.setInt(e.key, e.value as int);
      } else if (e.value is double) {
        _p.setDouble(e.key, e.value as double);
      } else if (e.value is String) {
        _p.setString(e.key, e.value as String);
      }
    }
  }
}
