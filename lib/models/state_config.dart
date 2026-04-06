import 'task.dart';

enum EnergyState { fatigue, anxiety, normal, excited }

class StateConfig {
  final EnergyState state;
  final String label;
  final int energyLimit; // Лимит в %
  final double costMultiplier; // Множитель сложности
  final String message;
  final List<Tag>? allowedTags; // Какие теги разрешены (для Тревоги)
  final bool showOnlyP0; // Ограничение для Усталости

  const StateConfig({
    required this.state,
    required this.label,
    required this.energyLimit,
    required this.costMultiplier,
    required this.message,
    this.allowedTags,
    this.showOnlyP0 = false,
  });

  static Map<EnergyState, StateConfig> get all => {
        EnergyState.fatigue: const StateConfig(
          state: EnergyState.fatigue,
          label: 'Усталость',
          energyLimit: 40,
          costMultiplier: 1.5,
          message:
              'Режим усталости — только самое важное. Сделай хоть немного.',
          showOnlyP0: true,
        ),
        EnergyState.anxiety: const StateConfig(
          state: EnergyState.anxiety,
          label: 'Тревога',
          energyLimit: 60,
          costMultiplier: 1.2,
          message: 'Начни с малого. Ты уже здесь — это достаточно.',
          allowedTags: [Tag.isMechanical],
        ),
        EnergyState.normal: const StateConfig(
          state: EnergyState.normal,
          label: 'Обычное',
          energyLimit: 100,
          costMultiplier: 1.0,
          message: '',
        ),
        EnergyState.excited: const StateConfig(
          state: EnergyState.excited,
          label: 'Воодушевление',
          energyLimit: 120,
          costMultiplier: 0.8,
          message: 'Ты в ресурсе. Используй этот момент!',
        ),
      };

  static StateConfig fromLabel(String label) =>
      all.values.firstWhere((e) => e.label == label,
          orElse: () => all[EnergyState.normal]!);
}
