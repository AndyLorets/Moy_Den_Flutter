import '../models/task.dart';
import '../models/state_config.dart';
import 'data_service.dart';

class EnergyService {
  static final EnergyService instance = EnergyService._internal();
  EnergyService._internal();

  final _ds = DataService.instance;

  // Получить текущую конфигурацию на основе выбранного в DataService состояния
  StateConfig get currentConfig => StateConfig.fromLabel(_ds.morningState);

  // Рассчитать эффективную стоимость задачи с учетом множителя
  int getEffectiveCost(Task task) {
    return (task.energyCost * currentConfig.costMultiplier).round();
  }

  // Рассчитать оставшуюся энергию
  int getRemainingEnergy(List<Task> allTasks) {
    final config = currentConfig;
    final limit = config.energyLimit;
    int spent = 0;

    // Включаем бонусную задачу если состояние Воодушевление
    final tasks = [...allTasks];
    if (config.state == EnergyState.excited) {
      final bonus = _ds.bonusTask;
      if (!tasks.any((t) => t.id == bonus.id)) {
        tasks.add(bonus.copyWith(isCompleted: _ds.isTaskDone(bonus.id)));
      }
    }

    for (final task in tasks) {
      if (task.isCompleted) {
        spent += getEffectiveCost(task);
      }
    }

    return (limit - spent).clamp(0, limit);
  }

  // Фильтрация и подбор задач согласно бюджету и состоянию
  List<Task> getVisibleTasks(List<Task> tasks) {
    final config = currentConfig;

    // 1. Фильтр по тегам (для Тревоги: только механические)
    Iterable<Task> filtered = tasks;
    if (config.allowedTags != null) {
      filtered = tasks.where((t) =>
          t.tags.any((tag) => config.allowedTags!.contains(tag)) ||
          t.priority == Priority.P0);
    }

    // 2. Логика для Усталости (P0 + одна легкая)
    if (config.showOnlyP0) {
      final p0Tasks = filtered.where((t) => t.priority == Priority.P0).toList();
      final others = filtered
          .where((t) => t.priority != Priority.P0 && !t.isCompleted)
          .toList();
      others.sort((a, b) => a.energyCost.compareTo(b.energyCost));

      return [...p0Tasks, if (others.isNotEmpty) others.first];
    }

    // 3. Бюджетная фильтрация: P0 → P1 → P2, пока лимит не исчерпан
    final sorted = filtered.toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));

    final result = <Task>[];
    int budget = config.energyLimit;

    // Списываем уже потраченную энергию (выполненные задачи)
    for (final t in sorted) {
      if (t.isCompleted) {
        budget -= (t.energyCost * config.costMultiplier).round();
      }
    }
    budget = budget.clamp(0, config.energyLimit);

    for (final t in sorted) {
      final cost = (t.energyCost * config.costMultiplier).round();
      if (t.priority == Priority.P0) {
        // P0 всегда показываем
        result.add(t);
      } else if (t.isCompleted) {
        // Выполненные всегда показываем (чтобы пользователь видел прогресс)
        result.add(t);
      } else if (cost <= budget) {
        result.add(t);
        budget -= cost;
      }
      // Иначе задача не влезает в бюджет — скрываем
    }

    // 4. Воодушевление: добавляем бонусную isGrowth-задачу
    if (config.state == EnergyState.excited) {
      final bonus = _ds.bonusTask.copyWith(
        isCompleted: _ds.isTaskDone(_ds.bonusTask.id),
      );
      final alreadyPresent = result.any((t) => t.id == bonus.id);
      if (!alreadyPresent) {
        result.add(bonus);
      }
    }

    return result;
  }

  // Задачи скрытые из-за бюджета (не P0, не выполненные, не влезли в лимит)
  List<Task> getHiddenTasks(List<Task> tasks) {
    final visible = getVisibleTasks(tasks);
    final visibleIds = visible.map((t) => t.id).toSet();
    return tasks.where((t) => !visibleIds.contains(t.id)).toList();
  }

  // Заполнение бара (0.0–1.0) относительно текущего лимита состояния
  // При Усталости (лимит 40): 40/40 = 1.0 в начале, убывает при выполнении
  // При Воодушевлении (лимит 120): 120/120 = 1.0 в начале, убывает при выполнении
  double getEnergyPercent(List<Task> allTasks) {
    final limit = currentConfig.energyLimit;
    if (limit == 0) return 0;
    return getRemainingEnergy(allTasks) / limit;
  }

  // Реальный остаток энергии в % (для отображения цифры пользователю)
  int getRemainingPercent(List<Task> allTasks) {
    return getRemainingEnergy(allTasks);
  }

  // Цвет по реальному остатку (в %, от 0 до 120+)
  dynamic getEnergyColor(int remainingPercent) {
    if (remainingPercent > 60) return 0xFF27AE60; // Green
    if (remainingPercent > 30) return 0xFFF39C12; // Amber
    return 0xFFE74C3C; // Red
  }

  // Сохранение в стрит (через DataService) выполняется только если P0 закрыты
  bool isDaySuccessful(List<Task> tasks) {
    return tasks
        .where((t) => t.priority == Priority.P0)
        .every((t) => t.isCompleted);
  }
}
