import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/energy_service.dart';
import '../models/task.dart';
import '../models/state_config.dart';
import '../constants/strings.dart';

// Экран Focus Mode — одна задача на весь экран
class FocusModeScreen extends StatelessWidget {
  final Task task;
  final VoidCallback onDone;

  const FocusModeScreen({super.key, required this.task, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'ФОКУС',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: task.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _tagLabel(tag),
                      style: theme.textTheme.labelSmall,
                    ),
                  )).toList(),
                ),
              ],
              if (task.hint != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.hint!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (EnergyService.instance.currentConfig.state != EnergyState.anxiety)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FocusSessionScreen(task: task, onDone: onDone),
                      ),
                    ),
                    icon: const Icon(Icons.timer_outlined),
                    label: const Text('Запустить таймер'),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    DataService.instance.toggleTask(task.id);
                    onDone();
                    Navigator.pop(context);
                  },
                  child: const Text('Отметить выполненным'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _tagLabel(Tag tag) {
    switch (tag) {
      case Tag.isMechanical:
        return 'механическое';
      case Tag.isEssential:
        return 'важное';
      case Tag.isDeepWork:
        return 'глубокая работа';
      case Tag.isGrowth:
        return 'рост';
    }
  }
}

// Экран Focus Session — таймер обратного отсчёта
class FocusSessionScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onDone;

  const FocusSessionScreen(
      {super.key, required this.task, required this.onDone});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with SingleTickerProviderStateMixin {
  static const List<int> _durations = [5, 10, 15, 20, 25];
  int _selectedMinutes = 10;
  int _secondsLeft = 0;
  bool _running = false;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.task.timerMinutes ?? 10;
    _secondsLeft = _selectedMinutes * 60;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
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

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _secondsLeft = _selectedMinutes * 60;
    });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnxiety = EnergyService.instance.currentConfig.state == EnergyState.anxiety;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!isAnxiety && !_running) ...[
                Text(
                  'Выбери длительность',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _durations.map((m) {
                    final selected = m == _selectedMinutes;
                    return ChoiceChip(
                      label: Text('$m мин'),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _selectedMinutes = m;
                        _secondsLeft = m * 60;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              if (!isAnxiety) ...[
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    final scale =
                        _running ? 1.0 + _pulseController.value * 0.02 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: 6,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              _timeString,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
              Text(
                widget.task.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isAnxiety) ...[
                const SizedBox(height: 16),
                Text(
                  'Начни с малого. Ты уже здесь — это достаточно.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              if (!isAnxiety)
                Row(
                  children: [
                    if (_running || _secondsLeft < _selectedMinutes * 60)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetTimer,
                          child: const Text('Сбросить'),
                        ),
                      ),
                    if (_running || _secondsLeft < _selectedMinutes * 60)
                      const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _running ? _pauseTimer : _startTimer,
                        icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                        label: Text(_running ? 'Пауза' : 'Старт'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _onComplete,
                child: const Text('Завершить досрочно'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран Completion — после выполнения задачи
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

    // Тревога — после любой задачи
    if (config.state == EnergyState.anxiety) {
      return SupportMessages.anxietyAfterTask;
    }

    // Усталость + задача P0
    if (config.state == EnergyState.fatigue && task.priority == Priority.P0) {
      return SupportMessages.p0InFatigue;
    }

    // Воодушевление + задача isGrowth (включая бонусную)
    if (config.state == EnergyState.excited &&
        task.tags.contains(Tag.isGrowth)) {
      return SupportMessages.excitedBonusDone;
    }

    // Первая задача дня — только одна выполнена
    final allTasks = [...ds.morningTasks, ...ds.dayTasks, ...ds.eveningTasks];
    final doneCount = allTasks.where((t) => ds.isTaskDone(t.id)).length;
    if (doneCount == 1) {
      return SupportMessages.firstTaskDone;
    }

    // Дефолт по энергии
    if (energy < 0.1) return 'Лимит исчерпан. Пора восстановиться.';
    if (energy < 0.3) return 'Хорошая работа. Можно остановиться.';
    return 'Ты сделал шаг.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final energy = _getCurrentEnergy();
    final config = EnergyService.instance.currentConfig;

    final lowEnergy = energy < 0.3 || config.state == EnergyState.fatigue;
    final message = _buildMessage(energy, config);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text('✓', style: theme.textTheme.displayLarge),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: lowEnergy
                    ? OutlinedButton(
                        onPressed: onAnother,
                        child: const Text('Ещё одно'),
                      )
                    : FilledButton(
                        onPressed: onAnother,
                        child: const Text('Ещё одно'),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: lowEnergy
                    ? FilledButton(
                        onPressed: onEnough,
                        style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary),
                        child: const Text('Достаточно на сегодня'),
                      )
                    : OutlinedButton(
                        onPressed: onEnough,
                        child: const Text('Достаточно на сегодня'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
