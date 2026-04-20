# 🌱 Мой день — Flutter App

## Документация
- `reference/MoyDen_PDD_v3.docx` — главный продуктовый документ. Читай первым.
- `reference/pwa_reference.html` — рабочая PWA версия. Источник текстов задач, подсказок, справки и логики синхронизации.
- `PROGRESS.md` — текущий статус задач. Читай перед началом работы. Обновляй только когда я попрошу.

---

## Суть продукта
Адаптивный ежедневный трекер. Показывает одно следующее действие с учётом текущего запаса сил пользователя. Не перегружает — ведёт.

---

## Технический стек
- Flutter 3.27+ / Dart 3.6+
- Material 3 (`useMaterial3: true`)
- Riverpod — управление состоянием
- SharedPreferences — локальное хранение
- http — GitHub Gist API
- flutter_local_notifications — уведомления
- speech_to_text — голосовой ввод
- Тема: `ThemeMode.system` (авто по системе)
- Деплой: Android APK + Flutter Web → GitHub Pages

---

## Структура проекта
```
lib/
  screens/     — все экраны (по одному файлу на экран)
  widgets/     — EnergyBar, StateConfigBadge, TaskCard, BranchingTask...
  services/    — DataService, GistService, EnergyService
  models/      — Task, TaskBranch, StateConfig, Profile, EnergyState
  constants/   — strings.dart, keys.dart, tasks.dart
  providers/   — Riverpod провайдеры
reference/     — PDD + PWA как reference материал
PROGRESS.md    — статус задач
CLAUDE.md      — этот файл
```

---

## Экраны
| Файл | Экран |
|------|-------|
| `smart_entry_screen.dart` | Маршрутизация по времени + выбор состояния |
| `dashboard_screen.dart` | Energy Bar, стрик, карточка следующего шага |
| `focus_mode_screen.dart` | Одна задача на весь экран |
| `focus_session_screen.dart` | Таймер 5–25 мин (скрыт при Тревоге) |
| `completion_screen.dart` | Адаптивные кнопки по уровню энергии |
| `overview_screen.dart` | Все задачи по фазам, фильтр по StateConfig |
| `schedule_screen.dart` | Редактируемое расписание |
| `help_screen.dart` | Справка: корень проблемы, страхи, техники |
| `settings_screen.dart` | Gist, уведомления, профили, сброс |

---

## Модель задачи (Task)
```dart
class Task {
  final String id;
  final String title;
  final String? description;    // подробная инструкция, по "?"
  final String? hint;           // фраза-триггер для старта
  final Phase phase;            // morning | day | evening
  final Priority priority;      // P0 | P1 | P2
  final int energyCost;         // базовый расход в %
  final List<Tag> tags;         // isMechanical | isDeepWork | isGrowth | isEssential
  final int? timerMinutes;
  final TaskType type;          // simple | timer | branching
  final List<TaskBranch>? branches;
  final Recurrence recurrence;  // daily | weekdays | weekends | custom | once
  bool isCompleted;
  final bool isCustom;
}
```

---

## Система энергии
- Каждый день пользователь получает 100% энергии
- Каждая задача имеет `energyCost` — базовый расход в %
- Состояние применяет множитель к стоимости задач
- Energy Bar отображается вместо простого прогресс-бара

| Состояние | Лимит | Множитель | Видимые задачи |
|-----------|-------|-----------|----------------|
| Усталость | 40% | ×1.5 | P0 + легчайшая |
| Тревога | 60% | ×1.2 | Только isMechanical |
| Обычное | 100% | ×1.0 | Все задачи бюджета |
| Воодушевление | 120% | ×0.8 | Все + бонусная isGrowth |

---

## Логика стрика
**Стрик сохраняется если выполнены все P0 задачи.**
P1 и P2 на стрик не влияют. В режиме Усталости P1/P2 скрыты — стрик продолжается.

---

## SharedPreferences — ключи
| Ключ | Тип | Описание |
|------|-----|----------|
| `streak` | int | Дней подряд |
| `last_day` | String | Последний закрытый день |
| `state` | String | fatigue / anxiety / normal / excited |
| `energy_limit` | int | Лимит энергии (%) |
| `energy_remaining` | int | Оставшийся запас (%) |
| `t_{taskId}` | bool | Выполнена ли задача |
| `smysl` | String | Зачем я это делаю |
| `epoch` | String | Дата начала для учёбы |
| `motiv` | String | Из страха или свободы |
| `fear` | String | Что не сделал из-за страха |
| `insight` | String | Инсайт дня |
| `schedule` | JSON | Расписание |
| `gh_token` | String | GitHub токен |
| `profile` | JSON | Текущий профиль |
| `profiles` | JSON | Все профили |

---

## Правила для Claude Code
- Тексты задач и подсказок — только из `reference/pwa_reference.html`, не придумывай
- Все строки интерфейса — в `lib/constants/strings.dart`, только на русском
- Комментарии в коде — на русском
- Каждый экран — отдельный файл в `lib/screens/`
- Тема всегда `ThemeMode.system`
- Использовать Material 3 компоненты
- Анимации — плавные, ненавязчивые
- `PROGRESS.md` — не трогай сам, обновляй только по запросу

## Прогресс
### Текущий статус задач — в `PROGRESS.md`.
Перед началом работы читай его, обновляй когда я попрошу тебя, сам не трогай.
*🌱 Мой день · PDD v2.0 · 2026 · Adaptive Energy System*