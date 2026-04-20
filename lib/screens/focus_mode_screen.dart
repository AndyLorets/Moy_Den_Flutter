import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/energy_service.dart';
import '../models/task.dart';
import '../models/state_config.dart';
import '../constants/strings.dart';

// ── Focus Mode — одна задача на весь экран ────────────────────
class FocusModeScreen extends StatelessWidget {
  final Task task;
  final VoidCallback onDone;

  const FocusModeScreen({super.key, required this.task, required this.onDone});

  String _priorityLabel(Priority p) => switch (p) {
        Priority.P0 => 'P0',
        Priority.P1 => 'P1',
        Priority.P2 => 'P2',
      };

  bool get _isP0 => task.priority == Priority.P0;
  bool get _isAnxiety =>
      EnergyService.instance.currentConfig.state == EnergyState.anxiety;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Фоновый blob
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer
                    .withValues(alpha: 0.1),
              ),
            ),
          ),
          // Основной контент
          SafeArea(
            child: Column(
              children: [
                // Header с кнопкой назад
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                    ],
                  ),
                ),
                // Центральная область
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Чип приоритета
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isP0
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isP0 ? Icons.anchor : Icons.radio_button_checked,
                                size: 14,
                                color: _isP0
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isP0
                                    ? '${_priorityLabel(task.priority)} Якорь'
                                    : _priorityLabel(task.priority),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _isP0
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Название задачи
                        Text(
                          task.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (task.hint != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            task.hint!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 52),
                        // Кнопка «Поехали» или «Отметить»
                        if (!_isAnxiety) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FocusSessionScreen(
                                      task: task, onDone: onDone),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: const StadiumBorder(),
                                shadowColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                elevation: 6,
                              ),
                              child: const Text(
                                'Поехали',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              DataService.instance.toggleTask(task.id);
                              onDone();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Отметить выполненным'),
                          ),
                        ),
                        if (_isAnxiety) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Начни с малого. Ты уже здесь — это достаточно.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // FAB «Мне тяжело»
          Positioned(
            bottom: 32,
            right: 24,
            child: SafeArea(
              child: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.sentiment_dissatisfied),
                label: const Text('Мне тяжело',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Focus Session — таймер с пульсирующим кругом ──────────────
class FocusSessionScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onDone;

  const FocusSessionScreen(
      {super.key, required this.task, required this.onDone});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  static const List<int> _durations = [5, 10, 15, 20, 25];
  int _selectedMinutes = 10;
  int _secondsLeft = 0;
  bool _running = false;
  Timer? _timer;

  late AnimationController _pulseOuter;
  late AnimationController _pulseInner;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.task.timerMinutes ?? 10;
    _secondsLeft = _selectedMinutes * 60;

    _pulseOuter = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseInner = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseOuter.dispose();
    _pulseInner.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() {
          _secondsLeft = 0;
          _running = false;
        });
        _onComplete();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _onComplete() {
    DataService.instance.toggleTask(widget.task.id);
    widget.onDone();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => CompletionScreen(
          task: widget.task,
          onAnother: () => Navigator.popUntil(ctx, (r) => r.isFirst),
          onEnough: () => Navigator.popUntil(ctx, (r) => r.isFirst),
        ),
      ),
    );
  }

  String get _timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress =>
      _selectedMinutes > 0 ? 1 - _secondsLeft / (_selectedMinutes * 60) : 0;

  bool get _isAnxiety =>
      EnergyService.instance.currentConfig.state == EnergyState.anxiety;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Фоновые blob-элементы
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -60,
            child: AnimatedBuilder(
              animation: _pulseOuter,
              builder: (_, __) => Opacity(
                opacity: 0.05 + _pulseOuter.value * 0.05,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            right: -60,
            child: AnimatedBuilder(
              animation: _pulseInner,
              builder: (_, __) => Opacity(
                opacity: 0.05 + _pulseInner.value * 0.05,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondaryContainer,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
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
                    ],
                  ),
                ),
                // Название задачи
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'В процессе',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.task.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Выбор длительности (до старта, не тревога)
                if (!_isAnxiety && !_running && _secondsLeft == _selectedMinutes * 60) ...[
                  Wrap(
                    spacing: 8,
                    children: _durations.map((m) {
                      final sel = m == _selectedMinutes;
                      return ChoiceChip(
                        label: Text('$m мин'),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          _selectedMinutes = m;
                          _secondsLeft = m * 60;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                // Таймер-круг
                if (!_isAnxiety)
                  _TimerCircle(
                    timeString: _timeString,
                    progress: _progress,
                    pulseAnim: _pulseOuter,
                    running: _running,
                  )
                else
                  _AnxietyMode(taskTitle: widget.task.title),
                const Spacer(),
                // Кнопки управления
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    children: [
                      if (!_isAnxiety)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    _running ? _pauseTimer : _startTimer,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  _running ? 'Пауза' : 'Старт',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: _onComplete,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text(
                                  'Готово',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _onComplete,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Готово',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _onComplete,
                        child: const Text('Завершить досрочно'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // FAB
          Positioned(
            bottom: 24,
            right: 24,
            child: SafeArea(
              child: FloatingActionButton.extended(
                heroTag: 'focus_session_fab',
                onPressed: () {},
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.favorite),
                label: const Text('Мне тяжело',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Круглый таймер ────────────────────────────────────────────
class _TimerCircle extends StatelessWidget {
  final String timeString;
  final double progress;
  final AnimationController pulseAnim;
  final bool running;

  const _TimerCircle({
    required this.timeString,
    required this.progress,
    required this.pulseAnim,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) {
        final scale = running ? 1.0 + pulseAnim.value * 0.015 : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Внешнее кольцо
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                // Среднее кольцо
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
                // Прогресс-круг
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Время
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.05),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeString,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'минуты',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Режим тревоги (без таймера) ───────────────────────────────
class _AnxietyMode extends StatelessWidget {
  final String taskTitle;
  const _AnxietyMode({required this.taskTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            taskTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Начни с малого. Ты уже здесь — это достаточно.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completion Screen — экран успеха ──────────────────────────
class CompletionScreen extends StatelessWidget {
  final Task task;
  final VoidCallback onAnother;
  final VoidCallback onEnough;

  const CompletionScreen({
    super.key,
    required this.task,
    required this.onAnother,
    required this.onEnough,
  });

  double _getCurrentEnergy() {
    final ds = DataService.instance;
    final tasks = [
      ...ds.morningTasks,
      ...ds.dayTasks,
      ...ds.eveningTasks,
    ].map((t) => t.copyWith(isCompleted: ds.isTaskDone(t.id))).toList();
    return EnergyService.instance.getEnergyPercent(tasks);
  }

  String _buildMessage(double energy, StateConfig config) {
    final ds = DataService.instance;

    if (config.state == EnergyState.anxiety) {
      return SupportMessages.anxietyAfterTask;
    }
    if (config.state == EnergyState.fatigue && task.priority == Priority.P0) {
      return SupportMessages.p0InFatigue;
    }
    if (config.state == EnergyState.excited &&
        task.tags.contains(Tag.isGrowth)) {
      return SupportMessages.excitedBonusDone;
    }
    final allTasks = [...ds.morningTasks, ...ds.dayTasks, ...ds.eveningTasks];
    final doneCount = allTasks.where((t) => ds.isTaskDone(t.id)).length;
    if (doneCount == 1) return SupportMessages.firstTaskDone;
    if (energy < 0.1) return 'Лимит исчерпан. Пора восстановиться.';
    if (energy < 0.3) return 'Хорошая работа. Можно остановиться.';
    return 'Ты сделал шаг.';
  }

  String _energyStateLabel(StateConfig config, double energy) {
    if (config.state == EnergyState.fatigue) return 'Усталость';
    if (config.state == EnergyState.anxiety) return 'Тревога';
    if (config.state == EnergyState.excited) return 'Воодушевление';
    if (energy < 0.3) return 'Низкая энергия';
    if (energy < 0.6) return 'Средний запас';
    return 'Высокий потенциал';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energy = _getCurrentEnergy();
    final config = EnergyService.instance.currentConfig;
    final lowEnergy = energy < 0.3 || config.state == EnergyState.fatigue;
    final message = _buildMessage(energy, config);
    final energyLabel = _energyStateLabel(config, energy);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Фоновый blob
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.1,
                      left: MediaQuery.of(context).size.width * 0.2,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lowEnergy
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.1,
                      right: MediaQuery.of(context).size.width * 0.2,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // Конфетти-иконки
                  _ConfettiGrid(lowEnergy: lowEnergy),
                  const SizedBox(height: 28),
                  // Заголовок
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -1,
                      ),
                      children: [
                        const TextSpan(text: 'Ты сделал\n'),
                        TextSpan(
                          text: 'шаг.',
                          style: TextStyle(
                              color: lowEnergy
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Energy Insight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (lowEnergy
                                    ? theme.colorScheme.tertiaryContainer
                                    : theme.colorScheme.primaryContainer)
                                .withValues(alpha: 0.5),
                          ),
                          child: Icon(
                            lowEnergy
                                ? Icons.battery_2_bar
                                : Icons.battery_full,
                            color: lowEnergy
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Состояние: $energyLabel',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: lowEnergy
                                      ? theme.colorScheme.tertiary
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lowEnergy
                                    ? 'Рекомендуем небольшую паузу'
                                    : 'Есть силы продолжить',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Адаптивные кнопки
                  Column(
                    children: [
                      // Главная кнопка зависит от энергии
                      SizedBox(
                        width: double.infinity,
                        child: lowEnergy
                            ? FilledButton.icon(
                                onPressed: onEnough,
                                icon: const Icon(Icons.coffee),
                                label: const Text('Отдохнуть'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20),
                                  shape: const StadiumBorder(),
                                  backgroundColor:
                                      theme.colorScheme.tertiary,
                                  foregroundColor:
                                      theme.colorScheme.onTertiary,
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: onAnother,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Следующая задача'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      // Вторичная кнопка
                      SizedBox(
                        width: double.infinity,
                        child: lowEnergy
                            ? OutlinedButton.icon(
                                onPressed: onAnother,
                                icon: const Icon(Icons.arrow_forward,
                                    size: 16),
                                label: const Text('Следующая задача'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: const StadiumBorder(),
                                ),
                              )
                            : OutlinedButton(
                                onPressed: onEnough,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('Достаточно на сегодня'),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Цитата
                  Text(
                    '"Отдых — это не отсутствие действий, а восстановление ресурса."',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Конфетти-иконки ───────────────────────────────────────────
class _ConfettiGrid extends StatelessWidget {
  final bool lowEnergy;
  const _ConfettiGrid({required this.lowEnergy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (icon: Icons.spa,               color: theme.colorScheme.primary),
      (icon: Icons.favorite,          color: theme.colorScheme.tertiary),
      (icon: Icons.energy_savings_leaf,color: theme.colorScheme.secondary),
      (icon: Icons.celebration,       color: theme.colorScheme.tertiary),
      (icon: Icons.task_alt,          color: theme.colorScheme.primary),
      (icon: Icons.stars,             color: theme.colorScheme.secondary),
    ];

    return SizedBox(
      width: 200,
      height: 120,
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: items
            .map((e) => Icon(e.icon,
                color: e.color.withValues(alpha: 0.8), size: 32))
            .toList(),
      ),
    );
  }
}
