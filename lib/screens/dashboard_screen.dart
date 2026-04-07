import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import '../widgets/tip_sheet.dart';
import 'overview_screen.dart';
import 'focus_mode_screen.dart';
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
  final _smyslController = TextEditingController();
  final _fearController = TextEditingController();
  final _insightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _smyslController.text = _ds.smysl;
    _fearController.text = _ds.fear;
    _insightController.text = _ds.insight;
  }

  @override
  void dispose() {
    _smyslController.dispose();
    _fearController.dispose();
    _insightController.dispose();
    super.dispose();
  }

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

  void _showTip(String key) {
    final tip = Tips.all[key];
    if (tip == null) return;
    showTipSheet(context, title: tip['title']!, body: tip['body']!);
  }

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
            _Header(greeting: _greeting, streak: streak, study: study, state: state),
            const SizedBox(height: 14),

            // ── Прогресс ───────────────────────────────────
            _EnergyBar(fill: energyBarFill, remaining: energyRemaining),
            const SizedBox(height: 20),


            // ── Зачем я это делаю ──────────────────────────
            _SmyslCard(
              controller: _smyslController,
              onChanged: (v) => _ds.smysl = v,
            ),
            const SizedBox(height: 12),

            // ── Утренние блоки ─────────────────────────────
            if (phase == DayPhase.morning) ...[
              _ConflictCard(
                value: _ds.conflict,
                onChanged: (v) {
                  _ds.conflict = v;
                  _refresh();
                },
                onTip: () => _showTip('mc'),
              ),
              const SizedBox(height: 12),
              _StateCard(
                value: _ds.morningState,
                onChanged: (v) {
                  _ds.morningState = v;
                  _refresh();
                },
                onTip: () => _showTip('emo'),
              ),
              const SizedBox(height: 12),
            ],

            // ── Дневной блок — мотивация ───────────────────
            if (phase == DayPhase.day) ...[
              _MotivCard(
                value: _ds.motiv,
                onChanged: (v) {
                  _ds.motiv = v;
                  _refresh();
                },
                onTip: () => _showTip('dm'),
              ),
              const SizedBox(height: 12),
            ],

            // ── Вечерние блоки ─────────────────────────────
            if (phase == DayPhase.evening) ...[
              _AffirmCard(),
              const SizedBox(height: 12),
              _FearCard(
                controller: _fearController,
                onChanged: (v) => _ds.fear = v,
                onTip: () => _showTip('e2'),
              ),
              const SizedBox(height: 12),
              _InsightCard(
                controller: _insightController,
                onChanged: (v) => _ds.insight = v,
              ),
              const SizedBox(height: 12),
            ],

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

            // ── Все задачи ─────────────────────────────────
            SizedBox(
              width: double.infinity,
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
  final String state;
  const _Header(
      {required this.greeting, required this.streak, required this.study, required this.state});

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
            Row(
              children: [
                if (state.isNotEmpty) ...[
                  _StateBadge(state: state),
                  const SizedBox(width: 8),
                ],
                if (streak > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔥 $streak',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
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

// ── Зачем я это делаю ────────────────────────────────────────
class _SmyslCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SmyslCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// зачем я это делаю',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: null,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
              decoration: InputDecoration(
                hintText: smyslPlaceholder,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Конфликт бессознательного (утро) ─────────────────────────
class _ConflictCard extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onTip;
  const _ConflictCard(
      {required this.value, required this.onChanged, required this.onTip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('// конфликт бессознательного',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.1)),
                const Spacer(),
                _TipBtn(onTap: onTip),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              conflictQuestion,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ConflictOptions.all.map((opt) {
                final selected = value == opt['value'];
                return _ChoiceChip(
                  label: opt['label']!,
                  selected: selected,
                  selectedColor: switch (opt['value']) {
                    'align' => Colors.green,
                    'conflict' => Colors.red,
                    _ => Colors.orange,
                  },
                  onTap: () => onChanged(selected ? '' : opt['value']!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Состояние утра ───────────────────────────────────────────
class _StateCard extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onTip;
  const _StateCard(
      {required this.value, required this.onChanged, required this.onTip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('// состояние утра',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.1)),
                const Spacer(),
                _TipBtn(onTap: onTip),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MorningStates.all.map((s) {
                final selected = value == s;
                return _ChoiceChip(
                  label: s,
                  selected: selected,
                  selectedColor: theme.colorScheme.primary,
                  onTap: () => onChanged(selected ? '' : s),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Из какого состояния действовал (день) ────────────────────
class _MotivCard extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onTip;
  const _MotivCard(
      {required this.value, required this.onChanged, required this.onTip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('// из какого состояния действовал?',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.1)),
                const Spacer(),
                _TipBtn(onTap: onTip),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MotivBtn(
                    label: '😰 Из страха',
                    selected: value == 'fear',
                    selectedColor: Colors.red,
                    onTap: () => onChanged(value == 'fear' ? '' : 'fear'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MotivBtn(
                    label: '🚀 Из свободы',
                    selected: value == 'free',
                    selectedColor: Colors.green,
                    onTap: () => onChanged(value == 'free' ? '' : 'free'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Аффирмация (вечер) ───────────────────────────────────────
class _AffirmCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
            left: BorderSide(color: theme.colorScheme.tertiary, width: 3)),
      ),
      child: Text(
        Affirmations.evening,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          height: 1.7,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Что не сделал из-за страха (вечер) ──────────────────────
class _FearCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onTip;
  const _FearCard(
      {required this.controller, required this.onChanged, required this.onTip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('// что не сделал из-за страха?',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red.shade400, letterSpacing: 1.1)),
                const Spacer(),
                _TipBtn(onTap: onTip),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                hintText: 'Назови это — уже станет легче...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Инсайт дня (вечер) ──────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _InsightCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('// один инсайт дня',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green.shade600, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                hintText: 'Что понял сегодня?',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
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

// ── Все задачи сделаны ───────────────────────────────────────
// ── Баннер адаптации под состояние ──────────────────────────
class _StateBadge extends StatelessWidget {
  final String state;
  const _StateBadge({required this.state});

  ({String icon, Color color}) _props(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (state) {
      'Усталость'     => (icon: '😴', color: Colors.orange),
      'Тревога'       => (icon: '🌬️', color: Colors.red),
      'Воодушевление' => (icon: '⚡', color: scheme.primary),
      _               => (icon: '✓',  color: scheme.outline),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _props(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: p.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(p.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            state,
            style: theme.textTheme.labelSmall?.copyWith(
              color: p.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

// ── Вспомогательные виджеты ──────────────────────────────────

class _TipBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _TipBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Icon(Icons.question_mark,
            size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _ChoiceChip(
      {required this.label,
      required this.selected,
      required this.selectedColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedColor : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                selected ? selectedColor : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _MotivBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _MotivBtn(
      {required this.label,
      required this.selected,
      required this.selectedColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? selectedColor : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                selected ? selectedColor : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
