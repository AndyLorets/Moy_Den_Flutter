import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../models/task.dart';
import 'data_service.dart';

const _kProfiles = 'profiles_v2';
const _kActiveProfile = 'active_profile';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  ProfileService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'ProfileService.init() не был вызван');
    return _prefs!;
  }

  // ── Список профилей ──────────────────────────────────────────
  List<Profile> get profiles {
    final json = _p.getString(_kProfiles) ?? '[]';
    return Profile.decodeList(json);
  }

  void _saveProfiles(List<Profile> list) {
    _p.setString(_kProfiles, Profile.encodeList(list));
  }

  // ── Активный профиль ─────────────────────────────────────────
  String? get activeProfileId => _p.getString(_kActiveProfile);

  Profile? get activeProfile {
    final id = activeProfileId;
    if (id == null) return null;
    try {
      return profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── CRUD профилей ────────────────────────────────────────────
  Profile createProfile(String name) {
    final profile = Profile(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      customTasks: _snapshotCurrentCustomTasks(),
    );
    final list = profiles;
    list.add(profile);
    _saveProfiles(list);
    return profile;
  }

  void updateProfile(Profile profile) {
    final list = profiles;
    final idx = list.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) list[idx] = profile;
    _saveProfiles(list);
  }

  void deleteProfile(String id) {
    final list = profiles.where((p) => p.id != id).toList();
    _saveProfiles(list);
    if (activeProfileId == id) {
      _p.remove(_kActiveProfile);
    }
  }

  // ── Применить профиль ────────────────────────────────────────
  void applyProfile(Profile profile) {
    _p.setString(_kActiveProfile, profile.id);
    final ds = DataService.instance;
    // Заменяем кастомные задачи всех фаз
    for (final phase in ['morning', 'day', 'evening']) {
      final tasks = (profile.customTasks[phase] ?? [])
          .map((e) => Task.fromJson(e))
          .toList();
      final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
      ds.setRawPref('cu_$phase', encoded);
    }
  }

  // ── Сохранить текущие задачи в профиль ──────────────────────
  void saveCurrentToProfile(Profile profile) {
    final snapshot = _snapshotCurrentCustomTasks();
    final updated = Profile(
      id: profile.id,
      name: profile.name,
      customTasks: snapshot,
    );
    updateProfile(updated);
  }

  Map<String, List<Map<String, dynamic>>> _snapshotCurrentCustomTasks() {
    final ds = DataService.instance;
    return {
      'morning': ds.getCustomTasks('morning').map((t) => t.toJson()).toList(),
      'day':     ds.getCustomTasks('day').map((t) => t.toJson()).toList(),
      'evening': ds.getCustomTasks('evening').map((t) => t.toJson()).toList(),
    };
  }
}
