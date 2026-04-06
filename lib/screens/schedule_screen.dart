import 'package:flutter/material.dart';
import '../services/data_service.dart';

// Экран редактируемого расписания
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _ds = DataService.instance;
  final _timeCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  List<ScheduleItem> get _items => _ds.schedule;

  void _update(ScheduleItem item, {String? time, String? label}) {
    final updated = _ds.schedule;
    final idx = updated.indexWhere((e) => e.id == item.id);
    if (idx == -1) return;
    if (time != null) updated[idx].time = time;
    if (label != null) updated[idx].label = label;
    _ds.saveSchedule(updated);
  }

  void _delete(String id) {
    final updated = _ds.schedule.where((e) => e.id != id).toList();
    _ds.saveSchedule(updated);
    setState(() {});
  }

  void _add() {
    final time = _timeCtrl.text.trim().isEmpty ? '--:--' : _timeCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) return;
    final updated = _ds.schedule;
    updated.add(ScheduleItem(
      id: 'sc_${DateTime.now().millisecondsSinceEpoch}',
      time: time,
      label: label,
    ));
    _ds.saveSchedule(updated);
    _timeCtrl.clear();
    _labelCtrl.clear();
    setState(() {});
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Восстановить стандартный?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              _ds.resetSchedule();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('График дня'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'нажми на поле чтобы изменить',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // Строки расписания
          ...items.map((item) => _ScheduleRow(
                item: item,
                onTimeChanged: (v) => _update(item, time: v),
                onLabelChanged: (v) => _update(item, label: v),
                onDelete: () => _delete(item.id),
              )),
          const Divider(height: 1),
          // Добавить строку
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: InputDecoration(
                      hintText: '09:00',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _labelCtrl,
                    decoration: InputDecoration(
                      hintText: 'Название...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _add,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Восстановить стандартный'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Строка расписания ────────────────────────────────────────
class _ScheduleRow extends StatelessWidget {
  final ScheduleItem item;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onLabelChanged;
  final VoidCallback onDelete;

  const _ScheduleRow({
    required this.item,
    required this.onTimeChanged,
    required this.onLabelChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: TextFormField(
              initialValue: item.time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: onTimeChanged,
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: item.label,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: onLabelChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
