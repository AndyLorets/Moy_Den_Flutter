import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/energy_service.dart';
import '../models/task.dart';
import '../models/state_config.dart';
import '../widgets/tip_sheet.dart';
import 'focus_mode_screen.dart';
import 'task_builder_screen.dart';

class OverviewScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const OverviewScreen({super.key, required this.onChanged});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _ds = DataService.instance;

  // 0=Все, 1=Утро, 2=День, 3=Вечер
  int _filterIndex = 0;

  void _toggle(String id) {
    _ds.toggleTask(id);
    widget.onChanged();
    setState(() {});
  }

  Future<void> _openTaskBuilder({Task? existing, required String phase}) async {
    final result = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskBuilderScreen(existing: existing),
      ),
    );
    if (result != null) {
      _ds.saveCustomTask(result);
      widget.onChanged();
      setState(() {});
    }
  }

  void _removeCustom(String phase, String id) {
    _ds.removeCustomTask(phase, id);
    widget.onChanged();
    setState(() {});
  }

  void _openFocus(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusModeScreen(
          task: task,
          onDone: () {
            widget.onChanged();
            setState(() {});
          },
        ),
      ),
    );
    widget.onChanged();
    setState(() {});
  }

  List<Task> get _morningVisible =>
      EnergyService.instance.getVisibleTasks(_ds.morningTasks);
  List<Task> get _dayVisible =>
      EnergyService.instance.getVisibleTasks(_ds.dayTasks);
  List<Task> get _eveningVisible =>
      EnergyService.instance.getVisibleTasks(_ds.eveningTasks);
  List<Task> get _morningHidden =>
      EnergyService.instance.getHiddenTasks(_ds.morningTasks);
  List<Task> get _dayHidden =>
      EnergyService.instance.getHiddenTasks(_ds.dayTasks);
  List<Task> get _eveningHidden =>
      EnergyService.instance.getHiddenTasks(_ds.eveningTasks);

  int get _doneCount {
    final all = [
      ..._ds.morningTasks,
      ..._ds.dayTasks,
      ..._ds.eveningTasks,
      ..._ds.getCustomTasks('morning'),
      ..._ds.getCustomTasks('day'),
      ..._ds.getCustomTasks('evening'),
    ];
    return all.where((t) => _ds.isTaskDone(t.id)).length;
  }

  int get _totalCount {
    return _ds.morningTasks.length +
        _ds.dayTasks.length +
        _ds.eveningTasks.length +
        _ds.getCustomTasks('morning').length +
        _ds.getCustomTasks('day').length +
        _ds.getCustomTasks('evening').length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energyService = EnergyService.instance;
    final energyPercent = energyService.getRemainingPercent([
      ..._ds.morningTasks,
      ..._ds.dayTasks,
      ..._ds.eveningTasks,
    ].map((t) => t.copyWith(isCompleted: _ds.isTaskDone(t.id))).toList());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // TopBar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Мой день',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.energy_savings_leaf,
                      color: theme.colorScheme.primary),
                ],
              ),
            ),
            // Заголовок с состоянием
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ВАШЕ СОСТОЯНИЕ',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          _stateLabel(energyService.currentConfig.state),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      // Теги
                      Row(
                        children: [
                          _SmallChip(
                            icon: Icons.bolt,
                            label: '$energyPercent% энергии',
                            color: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          _SmallChip(
                            label: '$_totalCount задач',
                            color: theme.colorScheme.surfaceContainerHigh,
                            textColor: theme.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Фильтры
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'Все',   active: _filterIndex == 0, onTap: () => setState(() => _filterIndex = 0)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Утро',  active: _filterIndex == 1, onTap: () => setState(() => _filterIndex = 1)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'День',  active: _filterIndex == 2, onTap: () => setState(() => _filterIndex = 2)),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Вечер', active: _filterIndex == 3, onTap: () => setState(() => _filterIndex = 3)),
                  ],
                ),
              ),
            ),
            // Список задач
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                children: [
                  if (_filterIndex == 0 || _filterIndex == 1) ...[
                    _PhaseSection(
                      label: '☀️ Утро',
                      phase: 'morning',
                      visible: _morningVisible,
                      hidden: _morningHidden,
                      custom: _ds.getCustomTasks('morning'),
                      onToggle: _toggle,
                      onOpenBuilder: (t) => _openTaskBuilder(existing: t, phase: 'morning'),
                      onRemove: (id) => _removeCustom('morning', id),
                      onFocus: _openFocus,
                    ),
                  ],
                  if (_filterIndex == 0 || _filterIndex == 2) ...[
                    if (_filterIndex == 0) const SizedBox(height: 8),
                    _PhaseSection(
                      label: '⚡ День',
                      phase: 'day',
                      visible: _dayVisible,
                      hidden: _dayHidden,
                      custom: _ds.getCustomTasks('day'),
                      onToggle: _toggle,
                      onOpenBuilder: (t) => _openTaskBuilder(existing: t, phase: 'day'),
                      onRemove: (id) => _removeCustom('day', id),
                      onFocus: _openFocus,
                    ),
                  ],
                  if (_filterIndex == 0 || _filterIndex == 3) ...[
                    if (_filterIndex == 0) const SizedBox(height: 8),
                    _PhaseSection(
                      label: '🌙 Вечер',
                      phase: 'evening',
                      visible: _eveningVisible,
                      hidden: _eveningHidden,
                      custom: _ds.getCustomTasks('evening'),
                      onToggle: _toggle,
                      onOpenBuilder: (t) => _openTaskBuilder(existing: t, phase: 'evening'),
                      onRemove: (id) => _removeCustom('evening', id),
                      onFocus: _openFocus,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stateLabel(EnergyState state) => switch (state) {
        EnergyState.fatigue  => 'Усталость',
        EnergyState.anxiety  => 'Тревога',
        EnergyState.excited  => 'Воодушевление',
        EnergyState.normal   => 'Полон сил',
      };
}

// ── Секция фазы ───────────────────────────────────────────────
class _PhaseSection extends StatelessWidget {
  final String label;
  final String phase;
  final List<Task> visible;
  final List<Task> hidden;
  final List<Task> custom;
  final ValueChanged<String> onToggle;
  final ValueChanged<Task?> onOpenBuilder; // null = новая задача
  final ValueChanged<String> onRemove;
  final ValueChanged<Task> onFocus;

  const _PhaseSection({
    required this.label,
    required this.phase,
    required this.visible,
    required this.hidden,
    required this.custom,
    required this.onToggle,
    required this.onOpenBuilder,
    required this.onRemove,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ds = DataService.instance;

    // Находим P0 задачу для крупной карточки
    final p0Tasks = visible.where((t) => t.priority == Priority.P0).toList();
    final otherVisible = visible.where((t) => t.priority != Priority.P0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок фазы
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
        ),
        // Крупная P0-карточка
        if (p0Tasks.isNotEmpty)
          _P0Card(
            task: p0Tasks.first,
            done: ds.isTaskDone(p0Tasks.first.id),
            onToggle: () => onToggle(p0Tasks.first.id),
            onFocus: () => onFocus(p0Tasks.first),
            onTip: p0Tasks.first.hint != null
                ? () => showTipSheet(context,
                    title: p0Tasks.first.title, body: p0Tasks.first.hint!)
                : null,
          ),
        if (p0Tasks.length > 1) ...[
          const SizedBox(height: 8),
          ...p0Tasks.skip(1).map((t) => _TaskCard(
                task: t,
                done: ds.isTaskDone(t.id),
                onToggle: () => onToggle(t.id),
                onFocus: () => onFocus(t),
                onTip: t.hint != null
                    ? () => showTipSheet(context, title: t.title, body: t.hint!)
                    : null,
                locked: false,
              )),
        ],
        // P1/P2 задачи
        if (otherVisible.isNotEmpty) ...[
          if (p0Tasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'ОСНОВНЫЕ ЦЕЛИ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          ...otherVisible.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _TaskCard(
                  task: t,
                  done: ds.isTaskDone(t.id),
                  onToggle: () => onToggle(t.id),
                  onFocus: () => onFocus(t),
                  onTip: t.hint != null
                      ? () =>
                          showTipSheet(context, title: t.title, body: t.hint!)
                      : null,
                  locked: false,
                ),
              )),
        ],
        // Кастомные задачи
        ...custom.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _CustomTaskCard(
                task: t,
                done: ds.isTaskDone(t.id),
                onToggle: () => onToggle(t.id),
                onEdit: () => onOpenBuilder(t),
                onDelete: () => onRemove(t.id),
              ),
            )),
        // Добавить задачу
        _AddTaskButton(onTap: () => onOpenBuilder(null)),
        // Заблокированные
        if (hidden.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'БОНУС (${hidden.length})',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...hidden.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _TaskCard(
                  task: t,
                  done: ds.isTaskDone(t.id),
                  onToggle: () => onToggle(t.id),
                  onFocus: () => onFocus(t),
                  onTip: null,
                  locked: true,
                ),
              )),
        ],
      ],
    );
  }
}

// ── Крупная P0 карточка ───────────────────────────────────────
class _P0Card extends StatefulWidget {
  final Task task;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onFocus;
  final VoidCallback? onTip;

  const _P0Card({
    required this.task,
    required this.done,
    required this.onToggle,
    required this.onFocus,
    this.onTip,
  });

  @override
  State<_P0Card> createState() => _P0CardState();
}

class _P0CardState extends State<_P0Card> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка + тег
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.architecture,
                    color: theme.colorScheme.onPrimaryContainer, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Якорь P0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Название
          Text(
            widget.task.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.done
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
              decoration:
                  widget.done ? TextDecoration.lineThrough : null,
            ),
          ),
          if (widget.task.hint != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.task.hint!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          // Кнопки
          Row(
            children: [
              FilledButton(
                onPressed: widget.onFocus,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Начать',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              // Чекбокс с анимацией
              ScaleTransition(
                scale: _scale,
                child: GestureDetector(
                  onTap: () {
                    if (!widget.done) _ctrl.forward(from: 0);
                    widget.onToggle();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.done
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.done
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: widget.done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              if (widget.onTip != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: widget.onTip,
                  icon: Icon(Icons.help_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant),
                  style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Обычная карточка задачи ───────────────────────────────────
class _TaskCard extends StatefulWidget {
  final Task task;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onFocus;
  final VoidCallback? onTip;
  final bool locked;

  const _TaskCard({
    required this.task,
    required this.done,
    required this.onToggle,
    required this.onFocus,
    this.onTip,
    required this.locked,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _priorityDot(Priority p, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (p) {
      Priority.P0 => cs.error,
      Priority.P1 => cs.secondary,
      Priority.P2 => cs.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: widget.locked
            ? theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.4)
            : (_hovering
                ? theme.colorScheme.surfaceContainerLowest
                : theme.colorScheme.surfaceContainerLow),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Точка приоритета
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.locked
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : _priorityDot(widget.task.priority, context),
            ),
          ),
          const SizedBox(width: 12),
          // Текст
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: widget.done ? TextDecoration.lineThrough : null,
                    color: widget.done || widget.locked
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.task.energyCost}% • ${_priorityStr(widget.task.priority)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Иконка замка для заблокированных
          if (widget.locked)
            Icon(Icons.lock_outline,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4))
          else ...[
            if (widget.onTip != null)
              GestureDetector(
                onTap: widget.onTip,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.help_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            GestureDetector(
              onTap: widget.onFocus,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.play_circle_outline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 4),
            // Чекбокс
            ScaleTransition(
              scale: _scale,
              child: GestureDetector(
                onTap: () {
                  if (!widget.done) _ctrl.forward(from: 0);
                  widget.onToggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.done
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.done
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: widget.done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.locked) {
      // Blur-эффект для заблокированных
      return MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: Stack(
          children: [
            Opacity(opacity: 0.35, child: card),
            // При наведении показываем иконку замка крупнее
            if (_hovering)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open,
                          color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 8),
                      Text(
                        'Низкая энергия',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: card,
    );
  }

  String _priorityStr(Priority p) => switch (p) {
        Priority.P0 => 'Якорь',
        Priority.P1 => 'Цель',
        Priority.P2 => 'Бонус',
      };
}

// ── Кастомная задача ──────────────────────────────────────────
class _CustomTaskCard extends StatelessWidget {
  final Task task;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomTaskCard({
    required this.task,
    required this.done,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? theme.colorScheme.primary : Colors.transparent,
                border: Border.all(
                  color: done
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? theme.colorScheme.onSurfaceVariant : null,
                  ),
                ),
                Text(
                  '${task.energyCost}% · ${_priorityLabel(task.priority)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.edit_outlined,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _priorityLabel(Priority p) => switch (p) {
    Priority.P0 => 'Якорь',
    Priority.P1 => 'Цель',
    Priority.P2 => 'Бонус',
  };
}

// ── Кнопка добавления задачи ──────────────────────────────────
class _AddTaskButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTaskButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Добавить задачу',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Мелкий чип ───────────────────────────────────────────────
class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _SmallChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Фильтр-чип ────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
