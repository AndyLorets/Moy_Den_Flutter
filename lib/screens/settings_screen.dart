import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/gist_service.dart';

// Экран настроек
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ds = DataService.instance;
  late final GistService _gist;
  final _tokenCtrl = TextEditingController();

  SyncStatus _syncStatus = SyncStatus.idle;
  String _syncMessage = '';

  @override
  void initState() {
    super.initState();
    _gist = GistService(_ds);
    _syncMessage = _ds.ghToken.isNotEmpty ? 'Токен настроен ✓' : 'Не настроено';
    _syncStatus = _ds.ghToken.isNotEmpty ? SyncStatus.ok : SyncStatus.idle;
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    super.dispose();
  }

  void _saveToken() {
    final val = _tokenCtrl.text.trim();
    if (val.isEmpty) {
      _showSnack('Введи токен');
      return;
    }
    _ds.ghToken = val;
    _tokenCtrl.clear();
    setState(() {
      _syncStatus = SyncStatus.ok;
      _syncMessage = 'Токен сохранён ✓';
    });
  }

  Future<void> _syncTo() async {
    setState(() {
      _syncStatus = SyncStatus.loading;
      _syncMessage = 'Сохраняю в облако...';
    });
    final result = await _gist.syncToGist();
    setState(() {
      _syncStatus = result;
      _syncMessage = result == SyncStatus.ok
          ? 'Синхронизировано ✓'
          : 'Ошибка сохранения';
    });
    if (result == SyncStatus.ok) _showSnack('Данные сохранены в облако!');
  }

  Future<void> _syncFrom() async {
    setState(() {
      _syncStatus = SyncStatus.loading;
      _syncMessage = 'Загружаю из облака...';
    });
    final result = await _gist.syncFromGist();
    setState(() {
      _syncStatus = result;
      _syncMessage = result == SyncStatus.ok ? 'Загружено ✓' : 'Ошибка загрузки';
    });
    if (result == SyncStatus.ok) _showSnack('Данные загружены из облака!');
  }

  void _resetDay() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сбросить сегодняшний день?'),
        content: const Text('Стрик, смысл и график сохранятся.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              _ds.resetDay();
              Navigator.pop(context);
              _showSnack('День сброшен');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'синхронизация и управление',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── GitHub Gist ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// GitHub Gist — синхронизация',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Статус
                  Row(
                    children: [
                      _SyncDot(status: _syncStatus),
                      const SizedBox(width: 8),
                      Text(_syncMessage, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Поле токена
                  TextField(
                    controller: _tokenCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Вставь GitHub Token (ghp_...)',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saveToken,
                      child: const Text('Сохранить токен'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Токен хранится только на этом устройстве. Нужен scope: gist.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _syncStatus == SyncStatus.loading ? null : _syncTo,
                          child: const Text('☁️ В облако'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _syncStatus == SyncStatus.loading ? null : _syncFrom,
                          child: const Text('📥 Из облака'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _ds.autosync = !_ds.autosync;
                        setState(() {});
                        _showSnack(
                            'Автосинхронизация ${_ds.autosync ? "включена" : "выключена"}');
                      },
                      child: Text(
                        '⚡ Автосинхронизация: ${_ds.autosync ? "вкл" : "выкл"}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Уведомления ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// напоминания',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Утро (9:00) и вечер (21:30)',
                                style: theme.textTheme.bodyMedium),
                            Text('Требуется настройка через систему',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Сброс ────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// сброс',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetDay,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                      ),
                      child: const Text('Сбросить сегодняшний день'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Цветной индикатор статуса синхронизации ──────────────────
class _SyncDot extends StatelessWidget {
  final SyncStatus status;
  const _SyncDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case SyncStatus.ok:
        color = Colors.green;
      case SyncStatus.error:
        color = Colors.red;
      case SyncStatus.loading:
        color = Colors.orange;
      case SyncStatus.idle:
        color = Theme.of(context).colorScheme.outlineVariant;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
