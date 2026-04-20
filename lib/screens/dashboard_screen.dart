import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import '../widgets/tip_sheet.dart';
import 'overview_screen.dart';
import 'focus_mode_screen.dart';
import 'reflection_screen.dart';
import 'help_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';
import '../services/energy_service.dart';
import '../models/task.dart';
import '../models/state_config.dart';

enum DayPhase { morning, day, evening }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ds = DataService.instance;
  DayPhase? _debugPhase;
  int _navIndex = 0;

  DayPhase get _phase {
    if (_debugPhase != null) return _debugPhase!;
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return DayPhase.morning;
    if (h >= 11 && h < 18) return DayPhase.day;
    return DayPhase.evening;
  }

  String get _greeting {
    switch (_phase) {
      case DayPhase.morning: return 'Доброе утро';
      case DayPhase.day:     return 'Добрый день';
      case DayPhase.evening: return 'Добрый вечер';
    }
  }

  List<Task> get _allTasks => _ds.allFixedTasks
      .map((t) => t.copyWith(isCompleted: _ds.isTaskDone(t.id)))
      .toList();

  List<Task> get _visibleTasksForPhase {
    final phaseEnum = switch (_phase) {
      DayPhase.morning => Phase.morning,
      DayPhase.day     => Phase.day,
      DayPhase.evening => Phase.evening,
    };
    final phaseTasks = _allTasks.where((t) => t.phase == phaseEnum).toList();
    return EnergyService.instance.getVisibleTasks(phaseTasks);
  }

  Task? get _nextTask {
    for (final t in _visibleTasksForPhase) {
      if (!t.isCompleted) return t;
    }
    return null;
  }

  bool get _isPhaseComplete {
    if (_nextTask != null) return false;
    final allVisible = EnergyService.instance.getVisibleTasks(_allTasks);
    return allVisible.any((t) => !t.isCompleted);
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

    final energyPercent = energyService.getRemainingPercent(_allTasks);
    final energyFill = energyService.getEnergyPercent(_allTasks);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Фоновый blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.15),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // TopAppBar
                _TopBar(
                  greeting: _greeting,
                  study: study,
                  onSettings: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                ),
                // Основной контент
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      const SizedBox(height: 8),
                      // Energy Bar editorial style
                      _EnergyBarEditorial(
                        percent: energyPercent,
                        fill: energyFill,
                        state: state,
                      ),
                      const SizedBox(height: 16),
                      // Стрик + выбор состояния
                      Row(
                        children: [
                          if (streak > 0)
                            _StreakBadge(streak: streak),
                          if (streak > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _StateSelector(
                              current: state,
                              onChanged: (v) {
                                _ds.morningState = v;
                                _refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Заголовок раздела
                      Text(
                        'Следующее действие',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Карточка задачи / фаза завершена / все готово
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
                      else if (_isPhaseComplete)
                        _PhaseDoneCard(phase: phase, onNavigate: _refresh)
                      else
                        _AllDoneCard(streak: streak),
                      const SizedBox(height: 16),
                      // Мини-прогресс
                      _ProgressGrid(allTasks: _allTasks),
                      const SizedBox(height: 16),
                      // Дебаг
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() {
                            _debugPhase = switch (phase) {
                              DayPhase.morning => DayPhase.day,
                              DayPhase.day     => DayPhase.evening,
                              DayPhase.evening => DayPhase.morning,
                            };
                          }),
                          child: Text(
                            'Фаза: ${switch (phase) {
                              DayPhase.morning => '☀️ Утро',
                              DayPhase.day     => '⚡ День',
                              DayPhase.evening => '🌙 Вечер',
                            }} (дебаг)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // FAB «Мне тяжело»
      floatingActionButton: _HardFab(
        onTap: () => _showHardSheet(context),
      ),
      // Нижняя навигация
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => OverviewScreen(onChanged: _refresh)));
          } else if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReflectionScreen()));
          } else if (i == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleScreen()));
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }

  void _showHardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _HardSheet(),
    );
  }
}

// ── Top App Bar ───────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String greeting;
  final StudyType study;
  final VoidCallback onSettings;
  const _TopBar(
      {required this.greeting, required this.study, required this.onSettings});

  String _formatDate() {
    final now = DateTime.now();
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг',
      'Пятница', 'Суббота', 'Воскресенье'
    ];
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Мой день',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StudyBadge(study: study),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: Icon(Icons.settings_outlined,
                color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

// ── Study badge ───────────────────────────────────────────────
class _StudyBadge extends StatelessWidget {
  final StudyType study;
  const _StudyBadge({required this.study});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = switch (study) {
      StudyType.english => Colors.green,
      StudyType.unity   => Colors.blue,
      StudyType.ai      => Colors.purple,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            study.label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Editorial Energy Bar ──────────────────────────────────────
class _EnergyBarEditorial extends StatelessWidget {
  final int percent;
  final double fill;
  final String state;

  const _EnergyBarEditorial({
    required this.percent,
    required this.fill,
    required this.state,
  });

  String get _label {
    if (percent >= 80) return 'Высокий потенциал';
    if (percent >= 50) return 'Средний запас';
    if (percent >= 20) return 'Низкая энергия';
    return 'Критический уровень';
  }

  Color _barColor(int p) {
    if (p >= 50) return const Color(0xFF27AE60);
    if (p >= 20) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _barColor(percent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ЭНЕРГИЯ',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fill.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Стрик ─────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department,
              color: Colors.orange, size: 18),
          const SizedBox(width: 6),
          Text(
            '$streak дн.',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
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
      (value: '',              label: 'Обычное',       emoji: '○',  color: theme.colorScheme.outline),
      (value: 'Усталость',    label: 'Усталость',     emoji: '😴', color: Colors.orange),
      (value: 'Тревога',      label: 'Тревога',       emoji: '🌬️', color: theme.colorScheme.secondary),
      (value: 'Воодушевление',label: 'Воодушевление', emoji: '⚡', color: theme.colorScheme.primary),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: states.map((s) {
          final selected = current == s.value;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChanged(s.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? s.color.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? s.color
                        : theme.colorScheme.outlineVariant,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(s.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: selected
                              ? s.color
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Bento-карточка следующего шага ───────────────────────────
class _NextStepCard extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;
  final VoidCallback? onTip;
  const _NextStepCard(
      {required this.task, required this.onStart, this.onTip});

  String _priorityLabel(Priority p) => switch (p) {
        Priority.P0 => 'P0',
        Priority.P1 => 'P1',
        Priority.P2 => 'P2',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isP0 = task.priority == Priority.P0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Теги
            Row(
              children: [
                _Tag(
                  label: _priorityLabel(task.priority),
                  color: isP0
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.surfaceContainerHigh,
                  textColor: isP0
                      ? theme.colorScheme.onTertiaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (isP0) ...[
                  const SizedBox(width: 6),
                  _Tag(
                    label: 'Якорь',
                    color: theme.colorScheme.secondaryContainer,
                    textColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ],
                const Spacer(),
                if (onTip != null)
                  IconButton(
                    onPressed: onTip,
                    icon: Icon(
                      Icons.more_horiz,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(28, 28)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Название
            Text(
              task.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            if (task.hint != null) ...[
              const SizedBox(height: 8),
              Text(
                task.hint!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            // Кнопка
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  shape: const StadiumBorder(),
                  shadowColor:
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                  elevation: 4,
                ),
                child: const Text('Начать',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Tag(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Фаза завершена ────────────────────────────────────────────
class _PhaseDoneCard extends StatelessWidget {
  final DayPhase phase;
  final VoidCallback onNavigate;
  const _PhaseDoneCard({required this.phase, required this.onNavigate});

  String get _phaseLabel => switch (phase) {
        DayPhase.morning => 'утро',
        DayPhase.day     => 'день',
        DayPhase.evening => 'вечер',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅  Ты выполнил все задачи на $_phaseLabel',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer)),
          const SizedBox(height: 8),
          Text('Отдохни или загляни сюда:',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer
                      .withValues(alpha: 0.7))),
          const SizedBox(height: 16),
          _NavButton(
            icon: Icons.list_alt,
            label: 'Задачи на день',
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          OverviewScreen(onChanged: onNavigate)));
              onNavigate();
            },
          ),
          const SizedBox(height: 8),
          _NavButton(
            icon: Icons.calendar_today,
            label: 'Расписание',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScheduleScreen())),
          ),
          const SizedBox(height: 8),
          _NavButton(
            icon: Icons.menu_book,
            label: 'Справка',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpScreen())),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Все задачи выполнены ──────────────────────────────────────
class _AllDoneCard extends StatelessWidget {
  final int streak;
  const _AllDoneCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('🎉', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Ты сделал шаг.',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Все задачи выполнены. Стрик: 🔥 $streak',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

// ── Мини-прогресс 2×2 ─────────────────────────────────────────
class _ProgressGrid extends StatelessWidget {
  final List<Task> allTasks;
  const _ProgressGrid({required this.allTasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = allTasks.where((t) => t.isCompleted).length;
    final total = allTasks.length;

    return Row(
      children: [
        // Выполнено
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.task_alt,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(height: 8),
                Text(
                  '$done/$total',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Задач выполнено',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Правая колонка
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule,
                        color: theme.colorScheme.secondary, size: 18),
                    const Spacer(),
                    Text(
                      'Обзор',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'В ритме',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── FAB «Мне тяжело» ─────────────────────────────────────────
class _HardFab extends StatelessWidget {
  final VoidCallback onTap;
  const _HardFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: const Color(0xFFE74C3C),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.sentiment_dissatisfied),
      label: const Text(
        'Мне тяжело',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
      shape: const StadiumBorder(),
    );
  }
}

// ── Нижняя навигация ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (icon: Icons.wb_sunny_outlined, activeIcon: Icons.wb_sunny, label: 'Сегодня'),
      (icon: Icons.list_alt_outlined,  activeIcon: Icons.list_alt,  label: 'Планы'),
      (icon: Icons.favorite_outline,   activeIcon: Icons.favorite,  label: 'Пульс'),
      (icon: Icons.history,            activeIcon: Icons.history,   label: 'Архив'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final active = index == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: active
                      ? BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.activeIcon : item.icon,
                        color: active
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet «Мне тяжело» ────────────────────────────────
class _HardSheet extends StatelessWidget {
  const _HardSheet();

  Task? _getMicroTask() {
    final ds = DataService.instance;
    final all = [...ds.morningTasks, ...ds.dayTasks, ...ds.eveningTasks];
    final mechanical = all
        .where((t) =>
            t.tags.contains(Tag.isMechanical) && !ds.isTaskDone(t.id))
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
                        child: Text(e.value,
                            style: theme.textTheme.bodyMedium)),
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
                    microTask?.title ??
                        'Встань, выпей воды, сделай три вдоха.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer),
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

