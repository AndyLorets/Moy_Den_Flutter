import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/keys.dart';
import '../constants/strings.dart';

// Модель задачи
class TaskItem {
  final String id;
  final String text;
  final List<String> tipKeys; // ключи подсказок
  final String? tag;
  final bool isCustom;

  const TaskItem({
    required this.id,
    required this.text,
    this.tipKeys = const [],
    this.tag,
    this.isCustom = false,
  });
}

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

  String get tag {
    switch (this) {
      case StudyType.english:
        return 'язык';
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
  List<TaskItem> get morningTasks {
    final study = todayStudy;
    return [
      const TaskItem(id: 'm_pose', text: TaskTexts.pose, tipKeys: ['pose']),
      const TaskItem(id: 'm_breath', text: TaskTexts.breath, tipKeys: ['breath']),
      const TaskItem(id: 'm_vis', text: TaskTexts.visualization, tipKeys: ['m1']),
      const TaskItem(id: 'm_affirm', text: TaskTexts.affirmation, tipKeys: ['m2']),
      TaskItem(
        id: study.taskId,
        text: study.label == 'Английский'
            ? TaskTexts.studyEnglish
            : study.label == 'Unity'
                ? TaskTexts.studyUnity
                : TaskTexts.studyAI,
        tipKeys: [study.tipKey],
        tag: study.tag,
      ),
    ];
  }

  List<TaskItem> get dayTasks => const [
        TaskItem(id: 'd_action', text: TaskTexts.jobAction, tipKeys: ['d1'], tag: 'поиск'),
        TaskItem(id: 'd_wild', text: TaskTexts.wildCard, tipKeys: ['d2'], tag: 'разрыв'),
        TaskItem(id: 'd_game', text: TaskTexts.ownGame, tipKeys: ['d3'], tag: 'игра'),
      ];

  List<TaskItem> get eveningTasks => const [
        TaskItem(id: 'e_log', text: TaskTexts.dayLog),
        TaskItem(id: 'e_shadow', text: TaskTexts.shadowDebug, tipKeys: ['e2']),
        TaskItem(id: 'e_let', text: TaskTexts.letGo, tipKeys: ['e3']),
      ];

  // ── Адаптированные задачи по состоянию ──────────────────
  // Усталость → только 2 первые задачи утра + 1 дня
  // Воодушевление → все задачи + бонусная
  // Тревога → задачи в обычном порядке, но дыхание идёт первым (уже первое в списке)
  // Остальные → все задачи без изменений

  List<TaskItem> get adaptedMorningTasks {
    final state = morningState;
    final tasks = morningTasks;
    if (state == 'Усталость') return tasks.take(2).toList();
    if (state == 'Воодушевление') return [...tasks, _bonusTask];
    return tasks;
  }

  List<TaskItem> get adaptedDayTasks {
    final state = morningState;
    final tasks = dayTasks;
    if (state == 'Усталость') return tasks.take(1).toList();
    if (state == 'Воодушевление') return tasks;
    return tasks;
  }

  // Бонусная задача для состояния "Воодушевление"
  static const TaskItem _bonusTask = TaskItem(
    id: 'bonus_energy',
    text: 'Бонус: напиши одному человеку из индустрии — просто поздоровайся',
    tipKeys: ['d1'],
    tag: 'бонус',
  );

  // ── Кастомные задачи ────────────────────────────────────
  List<TaskItem> getCustomTasks(String phase) {
    final key = 'cu_$phase';
    final json = _p.getString(key) ?? '[]';
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => TaskItem(id: e['id'] as String, text: e['text'] as String, isCustom: true))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void addCustomTask(String phase, String text) {
    final key = 'cu_$phase';
    final tasks = getCustomTasks(phase);
    final newTask = {'id': 'cu_${DateTime.now().millisecondsSinceEpoch}', 'text': text};
    final encoded = jsonEncode([...tasks.map((t) => {'id': t.id, 'text': t.text}), newTask]);
    _p.setString(key, encoded);
  }

  void removeCustomTask(String phase, String id) {
    final key = 'cu_$phase';
    final tasks = getCustomTasks(phase).where((t) => t.id != id).toList();
    _p.setString(key, jsonEncode(tasks.map((t) => {'id': t.id, 'text': t.text}).toList()));
  }

  // ── Выполнение задач ────────────────────────────────────
  bool isTaskDone(String id) => _p.getBool(PrefKeys.taskPrefix + id) ?? false;

  void toggleTask(String id) {
    final key = PrefKeys.taskPrefix + id;
    _p.setBool(key, !(_p.getBool(key) ?? false));
    _checkStreakCompletion();
  }

  // ── Прогресс ────────────────────────────────────────────
  List<String> get allTaskIds {
    final ids = <String>[];
    for (final t in morningTasks) { ids.add(t.id); }
    for (final t in dayTasks) { ids.add(t.id); }
    for (final t in eveningTasks) { ids.add(t.id); }
    for (final t in getCustomTasks('morning')) { ids.add(t.id); }
    for (final t in getCustomTasks('day')) { ids.add(t.id); }
    for (final t in getCustomTasks('evening')) { ids.add(t.id); }
    return ids;
  }

  int get completedCount => allTaskIds.where(isTaskDone).length;
  int get totalCount => allTaskIds.length;

  // ── Стрик ────────────────────────────────────────────────
  int get streak => _p.getInt(PrefKeys.streak) ?? 0;

  void _checkStreakCompletion() {
    final ids = allTaskIds;
    final done = ids.where(isTaskDone).length;
    if (done == ids.length && ids.isNotEmpty) {
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
      return list.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultSchedule();
    }
  }

  void saveSchedule(List<ScheduleItem> items) {
    _p.setString(PrefKeys.schedule, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  List<ScheduleItem> _defaultSchedule() => DefaultSchedule.items
      .map((e) => ScheduleItem(id: e['id']!, time: e['time']!, label: e['label']!))
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
    // Сохраняем стрик, смысл, расписание, кастомные задачи, автосинх
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

  // ── Экспорт/импорт для Gist ─────────────────────────────
  Map<String, dynamic> exportData() {
    final keys = _p.getKeys();
    final data = <String, dynamic>{};
    for (final k in keys) {
      if (k == PrefKeys.ghToken) continue; // токен не синхронизируем
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
