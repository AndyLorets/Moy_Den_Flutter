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
    final limit = currentConfig.energyLimit;
    int spent = 0;

    for (final task in allTasks) {
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

    // 3. Воодушевление: добавляем бонусную isGrowth-задачу
    final result = filtered.toList();
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

  // Цвет для Energy Bar
  double getEnergyPercent(List<Task> allTasks) {
    final limit = currentConfig.energyLimit;
    if (limit == 0) return 0;
    return getRemainingEnergy(allTasks) / limit;
  }

  // Определение цвета для UI
  dynamic getEnergyColor(double percent) {
    if (percent > 0.6) return 0xFF4CAF50; // Green
    if (percent > 0.3) return 0xFFFFC107; // Amber
    return 0xFFF44336; // Red
  }

  // Сохранение в стрит (через DataService) выполняется только если P0 закрыты
  bool isDaySuccessful(List<Task> tasks) {
    return tasks
        .where((t) => t.priority == Priority.P0)
        .every((t) => t.isCompleted);
  }
}
