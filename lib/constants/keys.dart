// Ключи SharedPreferences — совместимы с PWA (localStorage)
class PrefKeys {
  static const String streak = 'streak';
  static const String lastDay = 'last_day';
  static const String smysl = 'smysl';
  static const String epoch = 'epoch';
  static const String state = 'state';
  static const String conflict = 'conflict';
  static const String motiv = 'motiv';
  static const String fear = 'fear';
  static const String insight = 'insight';
  static const String schedule = 'sc';
  static const String ghToken = 'gh_token';
  static const String autosync = 'autosync';

  // Кастомные задачи по фазам
  static const String customMorning = 'cu_morning';
  static const String customDay = 'cu_day';
  static const String customEvening = 'cu_evening';

  // Префикс выполненной задачи: 't_{taskId}'
  static const String taskPrefix = 't_';

  // Дата последнего показа Smart Entry (чтобы не показывать дважды в день)
  static const String lastEntryDay = 'last_entry_day';

  static String taskDone(String id) => 't_$id';
}
