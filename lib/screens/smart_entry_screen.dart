import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import '../widgets/tip_sheet.dart';
import 'dashboard_screen.dart' show DayPhase;

// Smart Entry — экран при первом открытии за день.
class SmartEntryScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SmartEntryScreen({super.key, required this.onDone});

  @override
  State<SmartEntryScreen> createState() => _SmartEntryScreenState();
}

class _SmartEntryScreenState extends State<SmartEntryScreen>
    with SingleTickerProviderStateMixin {
  final _ds = DataService.instance;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Для дебага: null = авто по времени, иначе принудительная фаза
  DayPhase? _debugPhase;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut),
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  DayPhase get _phase {
    if (_debugPhase != null) return _debugPhase!;
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return DayPhase.morning;
    if (h >= 11 && h < 18) return DayPhase.day;
    return DayPhase.evening;
  }

  void _cyclePhase() {
    setState(() {
      _debugPhase = switch (_phase) {
        DayPhase.morning => DayPhase.day,
        DayPhase.day => DayPhase.evening,
        DayPhase.evening => DayPhase.morning,
      };
    });
  }

  void _finish() {
    _ds.markEntryShown();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        body: SafeArea(
          child: switch (_phase) {
            DayPhase.morning => _MorningEntry(ds: _ds, onDone: _finish),
            DayPhase.day => _DayEntry(ds: _ds, onDone: _finish),
            DayPhase.evening => _EveningEntry(ds: _ds, onDone: _finish),
          },
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: _cyclePhase,
          tooltip: 'Сменить фазу (дебаг)',
          child: Text(switch (_phase) {
            DayPhase.morning => '☀️',
            DayPhase.day => '⚡',
            DayPhase.evening => '🌙',
          }),
        ),
      ),
    );
  }
}

// ── Утренний вход ────────────────────────────────────────────
class _MorningEntry extends StatefulWidget {
  final DataService ds;
  final VoidCallback onDone;
  const _MorningEntry({required this.ds, required this.onDone});

  @override
  State<_MorningEntry> createState() => _MorningEntryState();
}

class _MorningEntryState extends State<_MorningEntry> {
  late String _selectedState;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.ds.morningState;
  }

  void _selectState(String s) {
    final next = s == _selectedState ? '' : s;
    setState(() => _selectedState = next);
    widget.ds.morningState = next; // сохраняем сразу
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstTask = widget.ds.morningTasks.first;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text(
            'Доброе утро',
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Как ты сейчас?',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MorningStates.all.map((s) {
              final selected = _selectedState == s;
              final color = _stateColor(s, theme);
              return GestureDetector(
                onTap: () => _selectState(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          selected ? color : theme.colorScheme.outlineVariant,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    s,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color:
                          selected ? color : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Подсказка при тревоге
          if (_selectedState == 'Тревога') ...[
            _AnxietyHint(),
            const SizedBox(height: 16),
          ],

          // Подсказка при усталости
          if (_selectedState == 'Усталость') ...[
            _TiredHint(),
            const SizedBox(height: 16),
          ],

          // Первая задача
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Начни с',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(firstTask.title,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (firstTask.hint != null)
                  IconButton(
                    icon: const Icon(Icons.help_outline, size: 18),
                    onPressed: () {
                      showTipSheet(context,
                          title: firstTask.title, body: firstTask.hint!);
                    },
                    style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32)),
                  ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.onDone,
              child: Text(_selectedState.isEmpty ? 'Начать день' : 'Вперёд'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onDone,
              child: const Text('Пропустить'),
            ),
          ),
        ],
      ),
    );
  }

  Color _stateColor(String state, ThemeData theme) => switch (state) {
        'Тревога' => Colors.red,
        'Уверенность' => Colors.green,
        'Воодушевление' => Colors.blue,
        'Усталость' => Colors.orange,
        'Спокойствие' => theme.colorScheme.primary,
        _ => theme.colorScheme.onSurfaceVariant,
      };
}

// ── Дневной вход ─────────────────────────────────────────────
class _DayEntry extends StatelessWidget {
  final DataService ds;
  final VoidCallback onDone;
  const _DayEntry({required this.ds, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = ds.dayTasks.firstWhere(
      (t) => !ds.isTaskDone(t.id),
      orElse: () => ds.dayTasks.first,
    );
    final allDone = ds.dayTasks.every((t) => ds.isTaskDone(t.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('Добрый день',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            allDone ? 'Дневные задачи выполнены 🎉' : 'Главное действие дня:',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          if (!allDone)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      )),
                ],
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onDone, child: const Text('Открыть день')),
          ),
        ],
      ),
    );
  }
}

// ── Вечерний вход ────────────────────────────────────────────
class _EveningEntry extends StatelessWidget {
  final DataService ds;
  final VoidCallback onDone;
  const _EveningEntry({required this.ds, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = ds.completedCount;
    final total = ds.totalCount;
    final allDone = completed == total && total > 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('Добрый вечер',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            allDone ? 'Отличный день. Всё выполнено.' : 'Как прошёл день?',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Выполнено задач', style: theme.textTheme.bodyMedium),
                    Text('$completed / $total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                        allDone ? Colors.green : theme.colorScheme.primary),
                  ),
                ),
                if (ds.streak > 0) ...[
                  const SizedBox(height: 12),
                  Text('🔥 Стрик: ${ds.streak} дней',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
                if (ds.wasStreakBrokenToday) ...[
                  const SizedBox(height: 12),
                  Text(
                    SupportMessages.streakReset,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                  left:
                      BorderSide(color: theme.colorScheme.tertiary, width: 3)),
            ),
            child: Text(
              'Время дебаггинга — запиши что сделал, что не сделал и один инсайт.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onDone, child: const Text('Подвести итог')),
          ),
        ],
      ),
    );
  }
}

// ── Подсказка при тревоге ────────────────────────────────────
class _AnxietyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Дыхание — 60 секунд',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Вдох 4 сек → задержка 4 → выдох 8. Три цикла.\nДлинный выдох снижает тревогу через блуждающий нерв.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Подсказка при усталости ──────────────────────────────────
class _TiredHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Список сокращён. Сделай 2 задачи — это уже победа.\nПравило одного пропуска: никогда не пропускай два раза подряд.',
        style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
      ),
    );
  }
}
