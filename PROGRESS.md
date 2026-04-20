# Прогресс разработки — Мой день

## Roadmap

### ✅ Этап 1 — MVP (выполнено)
- Smart Entry, Dashboard, Focus Mode, Overview, локальное хранение

### ✅ Этап 2 — Core (выполнено)
- Focus Session, Completion Screen, FAB «Мне тяжело», Gist синхронизация, уведомления

### ✅ Этап 3 — Adaptive Energy (выполнено)
- [x] `EnergyService` — расчёт energyCost с мультипликатором
- [x] `StateConfig` — активный конфигуратор вместо информационной плашки
- [x] Energy Bar на Dashboard
- [x] Адаптивные кнопки на Completion Screen
- [x] Расширенная модель `Task` (priority, energyCost, tags)
- [x] `DataService` переведён на `Task` — реальные priority/energyCost/tags
- [x] `EnergyService.getVisibleTasks()` интегрирован в Dashboard и CompletionScreen
- [x] Стрик по P0-условию
- [x] Все тексты на русском

### ✅ Этап 3.5 — UI/UX v2 (выполнено)
- [x] `ReflectionScreen` — блоки рефлексии вынесены с Dashboard
- [x] Dashboard очищен: Header → Выбор состояния → Energy Bar → Следующий шаг
- [x] Inline выбор состояния (4 чипа) — без bottom sheet, поток сверху вниз
- [x] Состояния приведены к 4 по PDD: Обычное / Усталость / Тревога / Воодушевление
- [x] Бонусная задача при Воодушевлении
- [x] Таймер скрыт при Тревоге
- [x] Поддерживающие сообщения по контексту (раздел 6.3 PDD)
- [x] Бюджетная фильтрация задач P0→P1→P2
- [x] Микро-задача в FAB «Мне тяжело»
- [x] Анимация чекбокса в Overview

### ✅ Этап 3.6 — UI/UX v3 (выполнено)
- [x] `SmartEntryScreen` — bento 2×2 сетка состояний с offset-эффектом, blob-фоны
- [x] `DashboardScreen` — editorial Energy Bar (большой %), кастомный `_BottomNav`, `_NextStepCard` с цветной левой полосой, `_HardFab` красный FAB
- [x] `FocusModeScreen` — Stack с blob, P0-чип, headlineLarge заголовок
- [x] `FocusSessionScreen` — 3 кольца + `CircularProgressIndicator`, пульсирующие blob-анимации, режим Тревоги без таймера
- [x] `CompletionScreen` — конфетти-сетка иконок, Energy Insight Card, адаптивные кнопки по energyLevel
- [x] `OverviewScreen` — filter chips вместо TabBar, `_P0Card` с анимацией, заблокированные задачи через Opacity
- [x] `main.dart` упрощён — NavigationBar shell убран, Dashboard сам управляет навигацией
- [x] `colorSchemeSeed` изменён на зелёный `#006F1D` по UI_UX.md
- [x] `flutter build web` проходит без ошибок

### ✅ Этап 4 — Platform (частично выполнено)
- [x] `TaskBuilderScreen` — редактор кастомных задач: title, phase, priority, energyCost, tags, hint, timer
- [x] `DataService.saveCustomTask` — хранит полную модель Task (обратная совместимость со старым форматом)
- [x] `OverviewScreen` — кнопка «Добавить задачу» открывает TaskBuilder, кастомные задачи редактируемы
- [x] Модель `Profile` — снимок кастомных задач всех фаз с именем
- [x] `ProfileService` — CRUD профилей, применение, сохранение текущего состояния
- [x] `SettingsScreen` — блок «// профили задач»: создание, применение, сохранение, переименование, удаление
- [ ] Конструктор задач с ветками (branching) — не реализован
- [ ] Web деплой на GitHub Pages

### ✨ Этап 5 — Polish
- Анимации, haptic feedback, онбординг, статистика

---

## Сделано

### Инфраструктура
- [x] Зависимости: `shared_preferences`, `http`, `flutter_local_notifications`, `intl`
- [x] Структура папок: `lib/screens/`, `lib/widgets/`, `lib/services/`, `lib/constants/`
- [x] Все тексты в `lib/constants/strings.dart`
- [x] Ключи SharedPreferences в `lib/constants/keys.dart`

### Сервисы
- [x] `DataService` — хранение данных, стрик, чередование учёбы
- [x] `GistService` — синхронизация через GitHub Gist API
- [x] `EnergyService` — расчёт бюджета энергии и видимых задач

### Экраны
- [x] `DashboardScreen` — Header → Выбор состояния → Energy Bar → Следующий шаг
- [x] `ReflectionScreen` — рефлексия по фазам (утро/день/вечер)
- [x] `FocusModeScreen` — одна задача на весь экран
- [x] `FocusSessionScreen` — таймер 5–25 мин (скрыт при Тревоге)
- [x] `CompletionScreen` — адаптивные кнопки по уровню энергии
- [x] `OverviewScreen` — все задачи по вкладкам с фильтрацией по StateConfig
- [x] `ScheduleScreen` — редактируемое расписание
- [x] `HelpScreen` — справка
- [x] `SettingsScreen` — Gist синхронизация, сброс дня
- [x] `SmartEntryScreen` — умный вход по времени суток
- [x] FAB «Мне тяжело» — протокол поддержки

---

## Осталось сделать

> ⚠️ **Текущий фокус — реализация UI_UX.md.**
> Перед любой новой задачей сверяться с `UI_UX.md` — он описывает целевой интерфейс.

### 🔴 UI/UX — расхождения с UI_UX.md

- [x] **Цвета Energy Bar** — приведены к строгим HEX из UI_UX.md (`#27AE60` / `#F39C12` / `#E74C3C`)
- [x] **Dashboard: фаза завершена** — вместо задач из следующей фазы показывается `_PhaseDoneCard` с мотивирующим текстом и ссылками на Задачи / Расписание / Справку
- [x] **Все экраны** — SmartEntry, Dashboard, FocusMode, FocusSession, Completion, Overview полностью переписаны по UI_UX.md

### 🟢 Низкий приоритет — платформа и релиз

- [ ] **Деплой на Android** — `flutter build apk`, протестировать на телефоне
- [ ] **GitHub Pages** — задеплоить web-версию
- [ ] **Убрать дебаг-кнопку** смены фазы перед релизом
- [ ] **Branching tasks** — конструктор задач с ветками (TaskType.branching)
