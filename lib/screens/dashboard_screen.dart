import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import '../widgets/tip_sheet.dart';
import 'overview_screen.dart';
import 'focus_mode_screen.dart';
import 'reflection_screen.dart';
import '../services/energy_service.dart';
import '../models/task.dart';
import '../models/state_config.dart';

// Фаза дня
enum DayPhase { morning, day, evening }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ds = DataService.instance;

  // TODO: убрать _debugPhase перед релизом
  DayPhase? _debugPhase;

  DayPhase get _phase {
    if (_debugPhase != null) return _debugPhase!;
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return DayPhase.morning;
    if (h >= 11 && h < 18) return DayPhase.day;
    return DayPhase.evening;
  }

  String get _greeting {
    switch (_phase) {
      case DayPhase.morning:
        return 'Доброе утро';
      case DayPhase.day:
        return 'Добрый день';
      case DayPhase.evening:
        return 'Добрый вечер';
    }
  }

  // Все задачи с актуальным состоянием выполнения
  List<Task> get _allTasks {
    return _ds.allFixedTasks
        .map((t) => t.copyWith(isCompleted: _ds.isTaskDone(t.id)))
        .toList();
  }

  // Задачи текущей фазы, отфильтрованные EnergyService
  List<Task> get _visibleTasksForPhase {
    final phaseEnum = switch (_phase) {
      DayPhase.morning => Phase.morning,
      DayPhase.day => Phase.day,
      DayPhase.evening => Phase.evening,
    };
    final phaseTasks = _allTasks.where((t) => t.phase == phaseEnum).toList();
    return EnergyService.instance.getVisibleTasks(phaseTasks);
  }

  // Следующая невыполненная задача текущей фазы (адаптированная по состоянию)
  Task? get _nextTask {
    for (final t in _visibleTasksForPhase) {
      if (!t.isCompleted) return t;
    }
    // Если в текущей фазе всё сделано — ищем во всех видимых задачах
    final allVisible = EnergyService.instance.getVisibleTasks(_allTasks);
    for (final t in allVisible) {
      if (!t.isCompleted) return t;
    }
    return null;
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final energyService = EnergyService.instance;
    final study = _ds.todayStudy;
    final next = _nextTask;
    final streak = _ds.streak;
    final phase = _phase;
    final state = _ds.morningState;

    final energyBarFill = energyService.getEnergyPercent(_allTasks);
    final energyRemaining = energyService.getRemainingPercent(_allTasks);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            // ── Заголовок ──────────────────────────────────
            _Header(greeting: _greeting, streak: streak, study: study),
            const SizedBox(height: 14),

            // ── Выбор состояния ────────────────────────────
            _StateSelector(
              current: state,
              onChanged: (v) {
                _ds.morningState = v;
                _refresh();
              },
            ),
            const SizedBox(height: 14),

            // ── Прогресс ───────────────────────────────────
            _EnergyBar(fill: energyBarFill, remaining: energyRemaining),
            const SizedBox(height: 20),

            // ── Следующий шаг ──────────────────────────────
            if (next != null)
              _NextStepCard(
                task: next,
                onStart: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FocusModeScreen(task: next, onDone: _refresh),
                    ),
                  );
                  _refresh();
                },
                onTip: next.hint != null
                    ? () => showTipSheet(context,
                        title: next.title, body: next.hint!)
                    : null,
              )
            else
              _AllDoneCard(streak: streak),
            const SizedBox(height: 12),

            // ── Навигационные кнопки ───────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OverviewScreen(onChanged: _refresh),
                        ),
                      );
                      _refresh();
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Все задачи'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReflectionScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Рефлексия'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Кнопка дебага фазы ─────────────────────────
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _debugPhase = switch (phase) {
                    DayPhase.morning => DayPhase.day,
                    DayPhase.day => DayPhase.evening,
                    DayPhase.evening => DayPhase.morning,
                  };
                }),
                icon: Text(switch (phase) {
                  DayPhase.morning => '☀️',
                  DayPhase.day => '⚡',
                  DayPhase.evening => '🌙',
                }),
                label: Text(
                  'Фаза: ${switch (phase) {
                    DayPhase.morning => 'Утро',
                    DayPhase.day => 'День',
                    DayPhase.evening => 'Вечер',
                  }} (дебаг)',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHardSheet(context),
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.favorite_border),
        label: const Text('Мне тяжело'),
      ),
    );
  }

  void _showHardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _HardSheet(),
    );
  }
}

// ── Заголовок ────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String greeting;
  final int streak;
  final StudyType study;
  const _Header(
      {required this.greeting, required this.streak, required this.study});

  String _formatDate() {
    final now = DateTime.now();
    // Русские дни недели
    const days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    // Русские месяцы
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];
    final dayName = days[now.weekday % 7];
    final date = now.day;
    final month = months[now.month - 1];
    return '$dayName, $date $month';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Дата и день недели
        Text(
          _formatDate(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔥 $streak',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        _StudyBadge(study: study),
      ],
    );
  }
}

// ── Бейдж учёбы ─────────────────────────────────────────────
class _StudyBadge extends StatelessWidget {
  final StudyType study;
  const _StudyBadge({required this.study});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = switch (study) {
      StudyType.english => Colors.green,
      StudyType.unity => Colors.blue,
      StudyType.ai => Colors.purple,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            'Сегодня: ${study.label}',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Энерджи бар ──────────────────────────────────────────────
class _EnergyBar extends StatelessWidget {
  final double fill;       // 0.0–1.0 для прогресс-бара (relative to current limit)
  final int remaining;     // реальный остаток в % для отображения цифры

  const _EnergyBar({required this.fill, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energyService = EnergyService.instance;

    final colorValue = energyService.getEnergyColor(remaining);
    final color = Color(colorValue is int ? colorValue : 0xFF4CAF50);
    final isExcited = energyService.currentConfig.state == EnergyState.excited;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Запас сил',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Row(
              children: [
                if (isExcited)
                  Icon(Icons.bolt, size: 16, color: color),
                Text('$remaining%',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fill.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ── Следующий шаг ────────────────────────────────────────────
class _NextStepCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;
  final VoidCallback? onTip;
  const _NextStepCard(
      {required this.task, required this.onStart, this.onTip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('СЛЕДУЮЩИЙ ШАГ',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      letterSpacing: 1.5)),
              const Spacer(),
              if (onTip != null)
                IconButton(
                  onPressed: onTip,
                  icon: const Icon(Icons.help_outline, size: 18),
                  style: IconButton.styleFrom(
                      minimumSize: const Size(28, 28),
                      padding: EdgeInsets.zero),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer)),
          if (task.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(task.tags.first.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Начать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Inline выбор состояния ────────────────────────────────────
class _StateSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _StateSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final states = [
      (value: '',             label: 'Обычное',       icon: '○',  color: theme.colorScheme.outline),
      (value: 'Усталость',    label: 'Усталость',     icon: '😴', color: Colors.orange),
      (value: 'Тревога',      label: 'Тревога',       icon: '🌬️', color: Colors.red),
      (value: 'Воодушевление',label: 'Воодушевление', icon: '⚡', color: theme.colorScheme.primary),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: states.map((s) {
        final selected = current == s.value;
        return GestureDetector(
          onTap: () => onChanged(s.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? s.color.withValues(alpha: 0.12)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? s.color : theme.colorScheme.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(s.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: selected ? s.color : theme.colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  final int streak;
  const _AllDoneCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('🎉', style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('Ты сделал шаг.',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text('Все задачи выполнены. Стрик: 🔥 $streak',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}

// ── Мне тяжело (bottom sheet) ────────────────────────────────
class _HardSheet extends StatelessWidget {
  const _HardSheet();

  Task? _getMicroTask() {
    final ds = DataService.instance;
    final all = [...ds.morningTasks, ...ds.dayTasks, ...ds.eveningTasks];
    final mechanical = all
        .where((t) => t.tags.contains(Tag.isMechanical) && !ds.isTaskDone(t.id))
        .toList();
    if (mechanical.isEmpty) return null;
    mechanical.sort((a, b) => a.energyCost.compareTo(b.energyCost));
    return mechanical.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final microTask = _getMicroTask();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('ПРЯМО СЕЙЧАС',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(HelpTexts.panicTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...HelpTexts.panicSteps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.key + 1}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Expanded(
                        child:
                            Text(e.value, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    microTask?.title ?? 'Встань, выпей воды, сделай три вдоха.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Вернуться к дню'),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}


