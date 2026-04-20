import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskBuilderScreen extends StatefulWidget {
  final Task? existing; // null = создание, non-null = редактирование
  const TaskBuilderScreen({super.key, this.existing});

  @override
  State<TaskBuilderScreen> createState() => _TaskBuilderScreenState();
}

class _TaskBuilderScreenState extends State<TaskBuilderScreen> {
  final _titleCtrl = TextEditingController();
  final _hintCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Phase _phase = Phase.day;
  Priority _priority = Priority.P1;
  int _energyCost = 15;
  final Set<Tag> _tags = {};
  int? _timerMinutes;
  bool _hasTimer = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    if (t != null) {
      _titleCtrl.text = t.title;
      _hintCtrl.text = t.hint ?? '';
      _phase = t.phase;
      _priority = t.priority;
      _energyCost = t.energyCost;
      _tags.addAll(t.tags);
      _timerMinutes = t.timerMinutes;
      _hasTimer = t.timerMinutes != null;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _hintCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.existing?.id ?? 'cu_${DateTime.now().millisecondsSinceEpoch}';
    final task = Task(
      id: id,
      title: _titleCtrl.text.trim(),
      phase: _phase,
      priority: _priority,
      energyCost: _energyCost,
      tags: _tags.toList(),
      hint: _hintCtrl.text.trim().isEmpty ? null : _hintCtrl.text.trim(),
      timerMinutes: _hasTimer ? (_timerMinutes ?? 10) : null,
      isCompleted: widget.existing?.isCompleted ?? false,
      isCustom: true,
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать задачу' : 'Новая задача'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Сохранить',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Заголовок
            _SectionLabel(label: 'Что нужно сделать'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Название задачи...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введи название' : null,
            ),
            const SizedBox(height: 24),

            // Подсказка
            _SectionLabel(label: 'Подсказка (необязательно)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hintCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Фраза-триггер или инструкция...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            // Фаза
            _SectionLabel(label: 'Фаза'),
            const SizedBox(height: 10),
            _SegmentedRow<Phase>(
              values: Phase.values,
              selected: _phase,
              label: (p) => switch (p) {
                Phase.morning => '☀️ Утро',
                Phase.day => '⚡ День',
                Phase.evening => '🌙 Вечер',
              },
              onChanged: (p) => setState(() => _phase = p),
            ),
            const SizedBox(height: 24),

            // Приоритет
            _SectionLabel(label: 'Приоритет'),
            const SizedBox(height: 4),
            Text(
              'P0 — якорь дня (влияет на стрик), P1 — важное, P2 — бонус',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _SegmentedRow<Priority>(
              values: Priority.values,
              selected: _priority,
              label: (p) => p.name,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 24),

            // Стоимость энергии
            _SectionLabel(label: 'Стоимость энергии — $_energyCost%'),
            const SizedBox(height: 4),
            Text(
              'Лёгкая: 5–10%  ·  Средняя: 15–20%  ·  Тяжёлая: 25–30%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Slider(
              value: _energyCost.toDouble(),
              min: 5,
              max: 40,
              divisions: 7,
              label: '$_energyCost%',
              onChanged: (v) => setState(() => _energyCost = v.round()),
            ),
            const SizedBox(height: 24),

            // Теги
            _SectionLabel(label: 'Теги'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Tag.values.map((tag) {
                final active = _tags.contains(tag);
                return FilterChip(
                  label: Text(_tagLabel(tag)),
                  selected: active,
                  onSelected: (v) => setState(() {
                    if (v) _tags.add(tag); else _tags.remove(tag);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'isMechanical — автоматическое действие (видно при Тревоге)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Таймер
            _SectionLabel(label: 'Таймер'),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _hasTimer,
              onChanged: (v) => setState(() {
                _hasTimer = v;
                if (v) _timerMinutes ??= 10;
              }),
              title: const Text('Добавить таймер'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_hasTimer) ...[
              const SizedBox(height: 8),
              _SegmentedRow<int>(
                values: const [5, 10, 15, 20, 25],
                selected: _timerMinutes ?? 10,
                label: (m) => '$m мин',
                onChanged: (m) => setState(() => _timerMinutes = m),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _tagLabel(Tag tag) => switch (tag) {
    Tag.isMechanical => 'Механическое',
    Tag.isEssential  => 'Якорь',
    Tag.isDeepWork   => 'Глубокая работа',
    Tag.isGrowth     => 'Рост',
  };
}

// ── Секционный лейбл ──────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.primary,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Горизонтальный выбор ──────────────────────────────────────
class _SegmentedRow<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final void Function(T) onChanged;

  const _SegmentedRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: values.map((v) {
        final active = v == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                label(v),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: active
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
