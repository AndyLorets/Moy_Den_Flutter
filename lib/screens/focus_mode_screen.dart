import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/tip_sheet.dart';
import '../constants/strings.dart';

// Экран Focus Mode — одна задача на весь экран
class FocusModeScreen extends StatelessWidget {
  final TaskItem task;
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
                task.text,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              if (task.tag != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.tag!,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
              if (task.tipKeys.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    final tip = Tips.all[task.tipKeys.first];
                    if (tip != null) {
                      showTipSheet(context, title: tip['title']!, body: tip['body']!);
                    }
                  },
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Зачем это?'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              // Кнопка запуска таймера
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FocusSessionScreen(task: task, onDone: onDone),
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
}

// Экран Focus Session — таймер обратного отсчёта
class FocusSessionScreen extends StatefulWidget {
  final TaskItem task;
  final VoidCallback onDone;

  const FocusSessionScreen({super.key, required this.task, required this.onDone});

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
          taskText: widget.task.text,
          // "Ещё одно" — возвращаемся на дашборд (закрываем весь стек фокуса)
          onAnother: () => Navigator.popUntil(ctx, (r) => r.isFirst),
          // "Достаточно" — тоже на дашборд
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
              // Выбор длительности (только пока не запущен)
              if (!_running) ...[
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
              // Анимированный таймер
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  final scale = _running
                      ? 1.0 + _pulseController.value * 0.02
                      : 1.0;
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
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                widget.task.text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Кнопки управления
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
  final String taskText;
  final VoidCallback onAnother;
  final VoidCallback onEnough;

  const CompletionScreen({
    super.key,
    required this.taskText,
    required this.onAnother,
    required this.onEnough,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                'Ты сделал шаг.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                taskText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAnother,
                  child: const Text('Ещё одно'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
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
