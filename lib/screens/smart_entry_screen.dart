import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import 'dashboard_screen.dart' show DayPhase;

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

  DayPhase? _debugPhase;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
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

  void _finish() {
    _ds.markEntryShown();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        body: Stack(
          children: [
            // Фоновые blob-элементы
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.25),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.15),
                ),
              ),
            ),
            SafeArea(
              child: switch (_phase) {
                DayPhase.morning => _MorningEntry(ds: _ds, onDone: _finish),
                DayPhase.day => _DayEntry(ds: _ds, onDone: _finish),
                DayPhase.evening => _EveningEntry(ds: _ds, onDone: _finish),
              },
            ),
            // Дебаг-кнопка фазы
            Positioned(
              bottom: 16,
              left: 16,
              child: SafeArea(
                child: TextButton(
                  onPressed: () => setState(() {
                    _debugPhase = switch (_phase) {
                      DayPhase.morning => DayPhase.day,
                      DayPhase.day => DayPhase.evening,
                      DayPhase.evening => DayPhase.morning,
                    };
                  }),
                  child: Text(
                    switch (_phase) {
                      DayPhase.morning => '☀️ утро',
                      DayPhase.day => '⚡ день',
                      DayPhase.evening => '🌙 вечер',
                    },
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Утренний вход — bento-сетка состояний ──────────────────────
class _MorningEntry extends StatefulWidget {
  final DataService ds;
  final VoidCallback onDone;
  const _MorningEntry({required this.ds, required this.onDone});

  @override
  State<_MorningEntry> createState() => _MorningEntryState();
}

class _MorningEntryState extends State<_MorningEntry> {
  late String _selectedState;

  static const _states = [
    (value: 'Воодушевление', label: 'В восторге',  sub: 'High Energy', emoji: '🤩'),
    (value: '',              label: 'Хорошо',       sub: 'Balanced',    emoji: '😊'),
    (value: 'Усталость',    label: 'Устал(а)',      sub: 'Low Energy',  emoji: '😴'),
    (value: 'Тревога',      label: 'Тревожно',      sub: 'Focus needed',emoji: '😟'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedState = widget.ds.morningState;
  }

  void _selectState(String v) {
    setState(() => _selectedState = v);
    widget.ds.morningState = v;
  }

  Color _cardColor(String value, ThemeData theme, bool selected) {
    if (!selected) return theme.colorScheme.surface;
    return switch (value) {
      'Воодушевление' => theme.colorScheme.primaryContainer,
      'Усталость'     => Colors.orange.withValues(alpha: 0.15),
      'Тревога'       => theme.colorScheme.secondaryContainer,
      _               => theme.colorScheme.primaryContainer,
    };
  }

  Color _accentColor(String value, ThemeData theme) => switch (value) {
    'Воодушевление' => theme.colorScheme.primary,
    'Усталость'     => Colors.orange,
    'Тревога'       => theme.colorScheme.secondary,
    _               => theme.colorScheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Бейдж фазы
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'УТРЕННИЙ ПОТОК',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Заголовок
          RichText(
            text: TextSpan(
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              children: [
                const TextSpan(text: 'Как ты\n'),
                TextSpan(
                  text: 'сегодня?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Прислушайся к себе перед началом нового дня.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          // Bento-сетка 2×2
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: _states.asMap().entries.map((e) {
                final i = e.key;
                final s = e.value;
                final selected = _selectedState == s.value;
                final accent = _accentColor(s.value, theme);
                // Чередуем высоту через margin (имитация bento)
                final topOffset = (i == 1 || i == 3) ? 24.0 : 0.0;
                return Transform.translate(
                  offset: Offset(0, topOffset),
                  child: GestureDetector(
                    onTap: () => _selectState(s.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardColor(s.value, theme, selected),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? accent
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.emoji,
                              style: TextStyle(
                                fontSize: 32,
                                color: selected ? null : null,
                              )),
                          const Spacer(),
                          Text(
                            s.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? accent
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.sub,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Подсказка при тревоге/усталости
          if (_selectedState == 'Тревога') ...[
            _AnxietyHint(),
            const SizedBox(height: 12),
          ] else if (_selectedState == 'Усталость') ...[
            _TiredHint(),
            const SizedBox(height: 12),
          ],
          // Кнопки
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.onDone,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedState.isEmpty ? 'Начать день' : 'Вперёд',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.east, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onDone,
              child: Text(
                'Пропустить настройку',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'ДНЕВНОЙ ПОТОК',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Добрый день',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            allDone ? 'Дневные задачи выполнены 🎉' : 'Главное действие дня:',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          if (!allDone)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border(
                    left: BorderSide(
                        color: theme.colorScheme.primary, width: 4)),
              ),
              child: Text(task.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  )),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: const Text('Открыть день',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.nights_stay_outlined,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'ВЕЧЕРНИЙ ИТОГ',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Добрый вечер',
              style: theme.textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            allDone ? 'Отличный день. Всё выполнено.' : 'Как прошёл день?',
            style: theme.textTheme.bodyMedium
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
                    Text('Выполнено задач',
                        style: theme.textTheme.bodyMedium),
                    Text('$completed / $total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    minHeight: 8,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
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
              onPressed: onDone,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const StadiumBorder(),
              ),
              child: const Text('Подвести итог',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
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
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Дыхание — 60 секунд',
              style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600)),
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
