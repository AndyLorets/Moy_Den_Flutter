import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/task.dart';
import '../widgets/tip_sheet.dart';
import 'focus_mode_screen.dart';

// Экран Overview — полный список задач по фазам
class OverviewScreen extends StatefulWidget {
  final VoidCallback onChanged;
  const OverviewScreen({super.key, required this.onChanged});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with SingleTickerProviderStateMixin {
  final _ds = DataService.instance;
  late TabController _tabs;
  final _addMorningCtrl = TextEditingController();
  final _addDayCtrl = TextEditingController();
  final _addEveningCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final h = DateTime.now().hour;
    final initial = h < 11 ? 0 : h < 18 ? 1 : 2;
    _tabs = TabController(length: 3, vsync: this, initialIndex: initial);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _addMorningCtrl.dispose();
    _addDayCtrl.dispose();
    _addEveningCtrl.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    _ds.toggleTask(id);
    widget.onChanged();
    setState(() {});
  }

  void _addCustom(String phase, TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    _ds.addCustomTask(phase, text);
    ctrl.clear();
    widget.onChanged();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все задачи'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: '☀️ Утро'),
            Tab(text: '⚡ День'),
            Tab(text: '🌙 Вечер'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _PhaseTab(
            phase: 'morning',
            fixedTasks: _ds.morningTasks,
            customTasks: _ds.getCustomTasks('morning'),
            addCtrl: _addMorningCtrl,
            onToggle: _toggle,
            onAddCustom: () => _addCustom('morning', _addMorningCtrl),
            onRemoveCustom: (id) => _removeCustom('morning', id),
            onStartFocus: _openFocus,
          ),
          _PhaseTab(
            phase: 'day',
            fixedTasks: _ds.dayTasks,
            customTasks: _ds.getCustomTasks('day'),
            addCtrl: _addDayCtrl,
            onToggle: _toggle,
            onAddCustom: () => _addCustom('day', _addDayCtrl),
            onRemoveCustom: (id) => _removeCustom('day', id),
            onStartFocus: _openFocus,
          ),
          _PhaseTab(
            phase: 'evening',
            fixedTasks: _ds.eveningTasks,
            customTasks: _ds.getCustomTasks('evening'),
            addCtrl: _addEveningCtrl,
            onToggle: _toggle,
            onAddCustom: () => _addCustom('evening', _addEveningCtrl),
            onRemoveCustom: (id) => _removeCustom('evening', id),
            onStartFocus: _openFocus,
          ),
        ],
      ),
    );
  }
}

// ── Вкладка одной фазы ───────────────────────────────────────
class _PhaseTab extends StatelessWidget {
  final String phase;
  final List<Task> fixedTasks;
  final List<Task> customTasks;
  final TextEditingController addCtrl;
  final ValueChanged<String> onToggle;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;
  final ValueChanged<Task> onStartFocus;

  const _PhaseTab({
    required this.phase,
    required this.fixedTasks,
    required this.customTasks,
    required this.addCtrl,
    required this.onToggle,
    required this.onAddCustom,
    required this.onRemoveCustom,
    required this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    final ds = DataService.instance;
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        ...fixedTasks.map((t) => _TaskTile(
              task: t,
              done: ds.isTaskDone(t.id),
              onTap: () => onToggle(t.id),
              onFocus: () => onStartFocus(t),
              onTip: t.hint != null
                  ? () => showTipSheet(context, title: t.title, body: t.hint!)
                  : null,
            )),
        ...customTasks.map((t) => _CustomTaskTile(
              task: t,
              done: ds.isTaskDone(t.id),
              onTap: () => onToggle(t.id),
              onDelete: () => onRemoveCustom(t.id),
            )),
        _AddTaskRow(ctrl: addCtrl, onAdd: onAddCustom),
      ],
    );
  }
}

// ── Тайл фиксированной задачи ─────────────────────────────────
class _TaskTile extends StatelessWidget {
  final Task task;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onFocus;
  final VoidCallback? onTip;

  const _TaskTile({
    required this.task,
    required this.done,
    required this.onTap,
    required this.onFocus,
    this.onTip,
  });

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.P0:
        return 'P0';
      case Priority.P1:
        return 'P1';
      case Priority.P2:
        return 'P2';
    }
  }

  Color _priorityColor(Priority p, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (p) {
      case Priority.P0:
        return scheme.error;
      case Priority.P1:
        return scheme.primary;
      case Priority.P2:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
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
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _priorityColor(task.priority, context)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          _priorityLabel(task.priority),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _priorityColor(task.priority, context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (task.energyCost > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${task.energyCost}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onTip != null)
              _SmallButton(
                icon: Icons.help_outline,
                onTap: onTip!,
              ),
            _SmallButton(
              icon: Icons.play_circle_outline,
              onTap: onFocus,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Тайл кастомной задачи ─────────────────────────────────────
class _CustomTaskTile extends StatelessWidget {
  final Task task;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomTaskTile({
    required this.task,
    required this.done,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
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
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            _SmallButton(icon: Icons.close, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

// ── Строка добавления задачи ──────────────────────────────────
class _AddTaskRow extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onAdd;

  const _AddTaskRow({required this.ctrl, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Добавить задачу...',
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

// ── Маленькая иконка-кнопка ───────────────────────────────────
class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
