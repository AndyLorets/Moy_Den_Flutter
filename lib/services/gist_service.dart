import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_service.dart';

// Статус синхронизации
enum SyncStatus { idle, loading, ok, error }

// Сервис синхронизации через GitHub Gist
class GistService {
  static const String _filename = 'moiden_data.json';
  static const String _apiBase = 'https://api.github.com';

  final DataService _ds;
  String? _gistId;

  GistService(this._ds);

  Map<String, String> _headers(String token) => {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      };

  // Найти существующий gist или создать новый
  Future<String?> _findOrCreateGist(String token) async {
    if (_gistId != null) return _gistId;

    try {
      final res = await http.get(
        Uri.parse('$_apiBase/gists?per_page=100'),
        headers: _headers(token),
      );
      if (!res.ok) return null;

      final gists = jsonDecode(res.body) as List;
      final found = gists.cast<Map>().firstWhere(
            (g) => (g['files'] as Map?)?.containsKey(_filename) ?? false,
            orElse: () => {},
          );

      if (found.isNotEmpty) {
        _gistId = found['id'] as String;
        return _gistId;
      }

      // Создаём новый gist
      final createRes = await http.post(
        Uri.parse('$_apiBase/gists'),
        headers: _headers(token),
        body: jsonEncode({
          'description': 'Мой день — данные трекера',
          'public': false,
          'files': {
            _filename: {'content': '{}'}
          },
        }),
      );
      if (!createRes.ok) return null;

      _gistId = (jsonDecode(createRes.body) as Map)['id'] as String;
      return _gistId;
    } catch (_) {
      return null;
    }
  }

  // Сохранить данные в облако
  Future<SyncStatus> syncToGist() async {
    final token = _ds.ghToken;
    if (token.isEmpty) return SyncStatus.error;

    final id = await _findOrCreateGist(token);
    if (id == null) return SyncStatus.error;

    try {
      final data = _ds.exportData();
      final res = await http.patch(
        Uri.parse('$_apiBase/gists/$id'),
        headers: _headers(token),
        body: jsonEncode({
          'files': {
            _filename: {'content': jsonEncode(data)}
          },
        }),
      );
      return res.ok ? SyncStatus.ok : SyncStatus.error;
    } catch (_) {
      return SyncStatus.error;
    }
  }

  // Загрузить данные из облака
  Future<SyncStatus> syncFromGist() async {
    final token = _ds.ghToken;
    if (token.isEmpty) return SyncStatus.error;

    final id = await _findOrCreateGist(token);
    if (id == null) return SyncStatus.error;

    try {
      final res = await http.get(
        Uri.parse('$_apiBase/gists/$id'),
        headers: _headers(token),
      );
      if (!res.ok) return SyncStatus.error;

      final gistData = jsonDecode(res.body) as Map;
      final files = gistData['files'] as Map?;
      final content = files?[_filename]?['content'] as String?;
      if (content == null) return SyncStatus.error;

      final data = jsonDecode(content) as Map<String, dynamic>;
      _ds.importData(data);
      return SyncStatus.ok;
    } catch (_) {
      return SyncStatus.error;
    }
  }
}

extension on http.Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
