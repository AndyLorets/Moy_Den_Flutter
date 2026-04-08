import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../constants/strings.dart';
import '../widgets/tip_sheet.dart';

enum _Phase { morning, day, evening }

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final _ds = DataService.instance;
  late final TextEditingController _smyslController;
  late final TextEditingController _fearController;
  late final TextEditingController _insightController;

  @override
  void initState() {
    super.initState();
    _smyslController = TextEditingController(text: _ds.smysl);
    _fearController = TextEditingController(text: _ds.fear);
    _insightController = TextEditingController(text: _ds.insight);
  }

  @override
  void dispose() {
    _smyslController.dispose();
    _fearController.dispose();
    _insightController.dispose();
    super.dispose();
  }

  _Phase get _phase {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) return _Phase.morning;
    if (h >= 11 && h < 18) return _Phase.day;
    return _Phase.evening;
  }

  void _showTip(String key) {
    final tip = Tips.all[key];
    if (tip == null) return;
    showTipSheet(context, title: tip['title']!, body: tip['body']!);
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рефлексия'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── Зачем я это делаю ──────────────────────────────
          _SmyslCard(
            controller: _smyslController,
            onChanged: (v) => _ds.smysl = v,
          ),
          const SizedBox(height: 12),

          // ── Утренние блоки ─────────────────────────────────
          if (phase == _Phase.morning) ...[
            _ConflictCard(
              value: _ds.conflict,
              onChanged: (v) {
                _ds.conflict = v;
                setState(() {});
              },
              onTip: () => _showTip('mc'),
            ),
          ],

          // ── Дневной блок ───────────────────────────────────
          if (phase == _Phase.day) ...[
            _MotivCard(
              value: _ds.motiv,
              onChanged: (v) {
                _ds.motiv = v;
                setState(() {});
              },
              onTip: () => _showTip('dm'),
            ),
          ],

          // ── Вечерние блоки ─────────────────────────────────
          if (phase == _Phase.evening) ...[
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
          ],
        ],
      ),
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
