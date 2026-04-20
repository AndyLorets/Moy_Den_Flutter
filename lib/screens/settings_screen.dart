import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/gist_service.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';

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

          // ── Профили ──────────────────────────────────────
          _ProfilesCard(onChanged: () => setState(() {})),
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

// ── Карточка профилей ─────────────────────────────────────────
class _ProfilesCard extends StatefulWidget {
  final VoidCallback onChanged;
  const _ProfilesCard({required this.onChanged});

  @override
  State<_ProfilesCard> createState() => _ProfilesCardState();
}

class _ProfilesCardState extends State<_ProfilesCard> {
  final _ps = ProfileService.instance;

  void _createProfile() async {
    final name = await _showNameDialog(context, '');
    if (name == null || name.isEmpty) return;
    _ps.createProfile(name);
    widget.onChanged();
    setState(() {});
  }

  void _applyProfile(Profile p) {
    _ps.applyProfile(p);
    widget.onChanged();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Профиль «${p.name}» применён'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveCurrentToProfile(Profile p) {
    _ps.saveCurrentToProfile(p);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Текущие задачи сохранены в «${p.name}»'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _renameProfile(Profile p) async {
    final name = await _showNameDialog(context, p.name);
    if (name == null || name.isEmpty) return;
    p.name = name;
    _ps.updateProfile(p);
    setState(() {});
  }

  void _deleteProfile(Profile p) {
    _ps.deleteProfile(p.id);
    widget.onChanged();
    setState(() {});
  }

  Future<String?> _showNameDialog(BuildContext ctx, String initial) async {
    final ctrl = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Название профиля'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Обычный день, Поездка...'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profiles = _ps.profiles;
    final activeId = _ps.activeProfileId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '// профили задач',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _createProfile,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Создать'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            ),
            if (profiles.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Сохраняй наборы задач как профили — например «Обычный день» и «Поездка». Переключение меняет кастомные задачи.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              ...profiles.map((p) {
                final isActive = p.id == activeId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (isActive)
                        Icon(Icons.check_circle,
                            size: 16, color: theme.colorScheme.primary)
                      else
                        Icon(Icons.radio_button_unchecked,
                            size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      // Применить
                      if (!isActive)
                        GestureDetector(
                          onTap: () => _applyProfile(p),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              'Применить',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Сохранить текущее
                      GestureDetector(
                        onTap: () => _saveCurrentToProfile(p),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.save_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                      // Переименовать
                      GestureDetector(
                        onTap: () => _renameProfile(p),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                      // Удалить
                      GestureDetector(
                        onTap: () => _deleteProfile(p),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline,
                              size: 16,
                              color: theme.colorScheme.error.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
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
