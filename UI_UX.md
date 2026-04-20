<!-- Design System -->
# PRD: Мобильное приложение «Мой день»

## 1. Концепция
«Мой день» — это не просто таск-менеджер, а психологический партнер. Главная цель — помочь пользователю двигаться вперед без насилия над собой, адаптируя нагрузку под текущий уровень энергии.

## 2. Экраны и логика

### 1. Smart Entry (Вход в день)
- **Контекст:** Показывается при первом открытии приложения утром (до 11:00).
- **Иерархия:** Вопрос о состоянии -> Варианты выбора (Смайлы/Текст) -> Кнопка «Начать день».
- **Логика:** Определяет начальный % Energy Bar и фильтрует список задач (скрывает сложные, если энергия < 40%).

### 2. Dashboard (Главный экран)
- **Контекст:** Основной рабочий хаб.
- **Иерархия:** Energy Bar (верх) -> Стрик (дни подряд) -> Карточка «Следующее действие» (крупно) -> Прогресс дня.
- **Особенности:** Если энергия в красной зоне, карточка «Следующее действие» меняется на микро-шаг (например, «Просто открой ноутбук»).

### 3. Focus Mode (Режим фокуса)
- **Контекст:** Весь экран занимает одна задача. Никаких отвлекающих факторов.
- **Компоненты:** Название задачи, описание, кнопка «Поехали».
- **Состояния:** При тревоге скрываются любые индикаторы времени.

### 4. Focus Session (Таймер)
- **Контекст:** Процесс выполнения.
- **UI:** Крупный таймер (или пульсирующий круг), кнопка «Пауза», «Готово».
- **Анимация:** Плавное «дыхание» фона в такт таймеру.

### 5. Completion Screen (Экран успеха)
- **Контекст:** Сразу после завершения задачи.
- **UI:** Текст «Ты сделал шаг.», анимация конфетти (негромкая).
- **Адаптивность:** Если энергия низкая, кнопка «Отдохнуть» огромная, а «Следующая задача» маленькая. При высокой энергии — наоборот.

### 6. Overview (Обзор задач)
- **Контекст:** Список всех дел по фазам (Утро/День/Вечер).
- **UI:** Карточки с тегами P0 (Якорь), P1, P2.
- **Состояния:** Заблокированные задачи (если не хватает энергии) заблюрены или имеют иконку «Замок».

### 7. Задача с ветками (Интерактив)
- **Контекст:** Сложные задачи, требующие уточнения.
- **Логика:** Вопрос -> Варианты. Пример: «Тяжело начать?» -> [Да] -> Предложение разбить на подзадачи.

### 8. Конструктор задач (Bottom Sheet)
- **UI:** Поле ввода, выбор приоритета (P0/P1/P2), оценка «стоимости» в энергии.

### 9. Вечерний отчёт
- **Контекст:** После 20:00.
- **UI:** Итоги (что сделано), график энергии за день, поле для рефлексии (одним словом).

### 10. FAB «Мне тяжело»
- **UI:** Красная кнопка, всегда доступна.
- **Действие:** Открывает Bottom Sheet с дыхательным упражнением или предложением отменить все P1/P2 задачи на сегодня.

## 3. Технические требования (Flutter)
- Material 3, адаптивная тема.
- Локализация: RU.
- Шрифты: Inter.


<!-- PRD: Мой день (Структура приложения) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Мой день — Утренняя настройка</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-highest": "#dde4e0",
                    "on-secondary": "#fff8f0",
                    "primary-fixed": "#91f78e",
                    "on-secondary-fixed": "#523c00",
                    "secondary-fixed-dim": "#ffce5d",
                    "secondary": "#795a00",
                    "secondary-dim": "#6a4f00",
                    "on-surface-variant": "#59615d",
                    "on-tertiary-fixed": "#000000",
                    "on-tertiary-container": "#110000",
                    "surface-dim": "#d5dcd7",
                    "tertiary-fixed-dim": "#eb3c30",
                    "on-primary-container": "#005e17",
                    "primary": "#006f1d",
                    "error-container": "#fd795a",
                    "primary-container": "#91f78e",
                    "secondary-fixed": "#ffdf9e",
                    "on-error": "#fff7f6",
                    "on-primary-fixed": "#00480f",
                    "on-error-container": "#6e1400",
                    "background": "#f8faf7",
                    "on-tertiary": "#fff7f6",
                    "on-secondary-container": "#694d00",
                    "inverse-primary": "#91f78e",
                    "surface-bright": "#f8faf7",
                    "surface-container-high": "#e4e9e5",
                    "tertiary": "#bc1714",
                    "error": "#a73b21",
                    "on-tertiary-fixed-variant": "#340001",
                    "on-surface": "#2d3431",
                    "surface-tint": "#006f1d",
                    "outline-variant": "#acb4af",
                    "on-secondary-fixed-variant": "#755700",
                    "outline": "#757c79",
                    "secondary-container": "#ffdf9e",
                    "on-background": "#2d3431",
                    "primary-dim": "#006118",
                    "inverse-surface": "#0c0f0e",
                    "surface": "#f8faf7",
                    "surface-container-low": "#f1f5f1",
                    "surface-variant": "#dde4e0",
                    "tertiary-container": "#fd493b",
                    "surface-container": "#eaefeb",
                    "tertiary-dim": "#aa0208",
                    "on-primary": "#eaffe2",
                    "surface-container-lowest": "#ffffff",
                    "primary-fixed-dim": "#83e881",
                    "inverse-on-surface": "#9b9e9b",
                    "on-primary-fixed-variant": "#00691a",
                    "error-dim": "#791903",
                    "tertiary-fixed": "#fd493b"
            },
            "borderRadius": {
                    "DEFAULT": "1rem",
                    "lg": "2rem",
                    "xl": "3rem",
                    "full": "9999px"
            },
            "fontFamily": {
                    "headline": ["Inter"],
                    "body": ["Inter"],
                    "label": ["Inter"]
            }
          },
        },
      }
    </script>
<style>
        body {
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at top right, #eaffe2 0%, #f8faf7 60%, #f1f5f1 100%);
            min-height: 100vh;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .breathing-bg {
            background: radial-gradient(80% 80% at 50% 50%, rgba(145, 247, 142, 0.08) 0%, rgba(248, 250, 247, 0) 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="text-on-background overflow-hidden">
<!-- Content Canvas (focused journey, shells suppressed as per UX Goal) -->
<main class="relative z-10 min-h-screen flex flex-col items-center justify-between px-8 py-16 md:py-24 max-w-4xl mx-auto breathing-bg">
<!-- Header Section -->
<header class="w-full text-center space-y-6">
<div class="inline-flex items-center gap-2 px-4 py-2 bg-primary-container/30 rounded-full text-primary font-medium tracking-tight animate-pulse">
<span class="material-symbols-outlined text-lg" style="font-variation-settings: 'FILL' 1;">wb_sunny</span>
<span class="font-label text-sm uppercase tracking-widest">Утренний поток</span>
</div>
<h1 class="font-headline text-5xl md:text-7xl font-bold tracking-tighter text-on-surface leading-none">
                Как ты <br/><span class="text-primary italic">сегодня?</span>
</h1>
<p class="font-body text-on-surface-variant text-lg md:text-xl max-w-md mx-auto leading-relaxed opacity-80">
                Прислушайтесь к себе перед началом нового дня. Ваше состояние — ваш ориентир.
            </p>
</header>
<!-- Asymmetric Choice Grid (Bento Pattern) -->
<div class="w-full grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6 my-12">
<!-- Option: Excited -->
<button class="group flex flex-col items-start justify-between p-6 bg-surface-container-lowest rounded-lg hover:bg-primary-container transition-all duration-300 transform hover:-translate-y-2 aspect-square md:aspect-auto md:h-64">
<span class="text-4xl filter grayscale group-hover:grayscale-0 transition-all">🤩</span>
<div class="text-left">
<span class="block font-headline text-xl font-bold group-hover:text-on-primary-container">В восторге</span>
<span class="block font-label text-xs uppercase tracking-widest text-on-surface-variant group-hover:text-primary opacity-60">High Energy</span>
</div>
</button>
<!-- Option: Good -->
<button class="group flex flex-col items-start justify-between p-6 bg-surface-container-lowest rounded-lg hover:bg-primary-container transition-all duration-300 transform hover:-translate-y-2 aspect-square md:aspect-auto md:h-64 md:mt-8">
<span class="text-4xl filter grayscale group-hover:grayscale-0 transition-all">😊</span>
<div class="text-left">
<span class="block font-headline text-xl font-bold group-hover:text-on-primary-container">Хорошо</span>
<span class="block font-label text-xs uppercase tracking-widest text-on-surface-variant group-hover:text-primary opacity-60">Balanced</span>
</div>
</button>
<!-- Option: Tired -->
<button class="group flex flex-col items-start justify-between p-6 bg-surface-container-lowest rounded-lg hover:bg-tertiary-container/20 transition-all duration-300 transform hover:-translate-y-2 aspect-square md:aspect-auto md:h-64">
<span class="text-4xl filter grayscale group-hover:grayscale-0 transition-all">😴</span>
<div class="text-left">
<span class="block font-headline text-xl font-bold group-hover:text-tertiary">Устал(а)</span>
<span class="block font-label text-xs uppercase tracking-widest text-on-surface-variant group-hover:text-tertiary opacity-60">Low Energy</span>
</div>
</button>
<!-- Option: Anxious -->
<button class="group flex flex-col items-start justify-between p-6 bg-surface-container-lowest rounded-lg hover:bg-secondary-container transition-all duration-300 transform hover:-translate-y-2 aspect-square md:aspect-auto md:h-64 md:mt-8">
<span class="text-4xl filter grayscale group-hover:grayscale-0 transition-all">😟</span>
<div class="text-left">
<span class="block font-headline text-xl font-bold group-hover:text-on-secondary-container">Тревожно</span>
<span class="block font-label text-xs uppercase tracking-widest text-on-surface-variant group-hover:text-secondary opacity-60">Focus needed</span>
</div>
</button>
</div>
<!-- Action Footer -->
<footer class="w-full flex flex-col items-center gap-6">
<button class="group relative w-full max-w-sm px-8 py-5 bg-primary text-on-primary rounded-full font-headline text-xl font-semibold shadow-lg shadow-primary/20 hover:shadow-xl hover:shadow-primary/30 transition-all active:scale-95 overflow-hidden">
<span class="relative z-10 flex items-center justify-center gap-2">
                    Начать день
                    <span class="material-symbols-outlined">east</span>
</span>
<div class="absolute inset-0 bg-gradient-to-r from-primary via-primary-dim to-primary opacity-0 group-hover:opacity-100 transition-opacity"></div>
</button>
<button class="text-on-surface-variant font-label text-sm uppercase tracking-widest hover:text-primary transition-colors py-2">
                Пропустить настройку
            </button>
</footer>
</main>
<!-- Visual Embellishments: Soft Blobs -->
<div class="fixed top-[-10%] right-[-10%] w-[50vw] h-[50vw] bg-primary-container/20 blur-[120px] rounded-full -z-0"></div>
<div class="fixed bottom-[-10%] left-[-10%] w-[40vw] h-[40vw] bg-secondary-container/10 blur-[100px] rounded-full -z-0"></div>
<!-- Hidden Background Reference Image for Atmospheric Guide -->
<div class="hidden">
<img alt="atmosphere" data-alt="soft morning sunlight filtering through translucent curtains in a minimal white room with green plants in focus" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCyhIyMPZ8k51ckbuml-NRJ2_x17EAG56tUM2UbWRSTLd1DfLUZMX_3YL8fJ5hV9rJUGUw_04ZPeGoyvooLPHXE1GnUL2RPqHBFYtoX-JHb1fUL3hMBBXnDdRJXH0pNknTuLy2UgLgoaJ0_8wkYuONfPHlxG3ZL8MsMADRsRyUTqeMxLFdnLkv3Y5POZucb3_ZnL4nx5itJxltYsAQjAPEhh0DwdmcQIOEjvklpYvIph3cFHfvP8UMAvD0MlyKVSCAlNbnol5dJFg"/>
</div>
</body></html>

<!-- Smart Entry (Вход в день) -->
<!DOCTYPE html>

<html lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Мой день - Dashboard</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-container-highest": "#dde4e0",
                        "on-secondary": "#fff8f0",
                        "primary-fixed": "#91f78e",
                        "on-secondary-fixed": "#523c00",
                        "secondary-fixed-dim": "#ffce5d",
                        "secondary": "#795a00",
                        "secondary-dim": "#6a4f00",
                        "on-surface-variant": "#59615d",
                        "on-tertiary-fixed": "#000000",
                        "on-tertiary-container": "#110000",
                        "surface-dim": "#d5dcd7",
                        "tertiary-fixed-dim": "#eb3c30",
                        "on-primary-container": "#005e17",
                        "primary": "#006f1d",
                        "error-container": "#fd795a",
                        "primary-container": "#91f78e",
                        "secondary-fixed": "#ffdf9e",
                        "on-error": "#fff7f6",
                        "on-primary-fixed": "#00480f",
                        "on-error-container": "#6e1400",
                        "background": "#f8faf7",
                        "on-tertiary": "#fff7f6",
                        "on-secondary-container": "#694d00",
                        "inverse-primary": "#91f78e",
                        "surface-bright": "#f8faf7",
                        "surface-container-high": "#e4e9e5",
                        "tertiary": "#bc1714",
                        "error": "#a73b21",
                        "on-tertiary-fixed-variant": "#340001",
                        "on-surface": "#2d3431",
                        "surface-tint": "#006f1d",
                        "outline-variant": "#acb4af",
                        "on-secondary-fixed-variant": "#755700",
                        "outline": "#757c79",
                        "secondary-container": "#ffdf9e",
                        "on-background": "#2d3431",
                        "primary-dim": "#006118",
                        "inverse-surface": "#0c0f0e",
                        "surface": "#f8faf7",
                        "surface-container-low": "#f1f5f1",
                        "surface-variant": "#dde4e0",
                        "tertiary-container": "#fd493b",
                        "surface-container": "#eaefeb",
                        "tertiary-dim": "#aa0208",
                        "on-primary": "#eaffe2",
                        "surface-container-lowest": "#ffffff",
                        "primary-fixed-dim": "#83e881",
                        "inverse-on-surface": "#9b9e9b",
                        "on-primary-fixed-variant": "#00691a",
                        "error-dim": "#791903",
                        "tertiary-fixed": "#fd493b"
                    },
                    "borderRadius": {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Inter"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                },
            },
        }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .energy-gradient {
            background: radial-gradient(circle at top right, rgba(145, 247, 142, 0.15) 0%, rgba(248, 250, 247, 0) 50%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-surface selection:bg-primary-container min-h-screen pb-32 energy-gradient">
<!-- TopAppBar from JSON -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 dark:bg-stone-900/60 backdrop-blur-xl no-border bg-stone-100/50 dark:bg-stone-800/50">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-highest">
<img alt="User" class="w-full h-full object-cover" data-alt="close-up portrait of a serene person with soft lighting and natural background tones" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBlSvoxR1BEdLvSx-7wfKzhc0KHF9NDzuTFzj66Tpnh56eZ1rVt1LbaQ8Sn6Y1p81KQc8A9cMgc1XffMDu1fSqYfkYUNeeRFHTQ0FdhsgxliWXalTW2CGtI1MoUOpWhHIg7x_XuN_-8fRNlCpjYD9PjET36A5vbbKlv-TZgpW2mEzDe9xWA5KZ8gbBIDTJWSCy0z5vc89LnT0eD8RpDTWNb-A5mq9cnhZM77EctAoW9kHmiaLe2IpRD7Ys1ioOEmKwrvyAUEp7Www"/>
</div>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-800 dark:text-green-300">Мой день</h1>
</div>
<div class="p-2 rounded-full hover:bg-stone-200/50 transition-colors cursor-pointer active:scale-95 transition-transform duration-300">
<span class="material-symbols-outlined text-green-700 dark:text-green-400" data-icon="energy_savings_leaf">energy_savings_leaf</span>
</div>
</header>
<main class="pt-24 px-6 max-w-2xl mx-auto">
<!-- Energy Section -->
<section class="mb-10">
<div class="flex items-baseline justify-between mb-4">
<h2 class="text-[3.5rem] font-bold leading-none tracking-tighter text-on-surface">75%</h2>
<div class="flex flex-col items-end">
<span class="text-label-md font-medium text-primary uppercase tracking-widest">Энергия</span>
<span class="text-body-lg text-on-surface-variant italic">Высокий потенциал</span>
</div>
</div>
<div class="w-full h-4 bg-surface-container-high rounded-full overflow-hidden">
<div class="h-full w-3/4 bg-gradient-to-r from-primary to-primary-fixed rounded-full"></div>
</div>
</section>
<!-- Streak & Context -->
<section class="mb-12 flex items-center gap-4">
<div class="bg-surface-container-low px-6 py-4 rounded-lg flex items-center gap-3 flex-1">
<span class="material-symbols-outlined text-secondary" data-icon="local_fire_department" style="font-variation-settings: 'FILL' 1;">local_fire_department</span>
<span class="font-semibold text-on-surface">5 дней в ритме</span>
</div>
<div class="bg-primary-container/30 px-6 py-4 rounded-lg flex items-center justify-center">
<span class="material-symbols-outlined text-primary" data-icon="wb_sunny">wb_sunny</span>
</div>
</section>
<!-- Next Action Card (Bento Style Asymmetric) -->
<section class="mb-10">
<h3 class="text-headline-md font-semibold mb-6 text-on-surface px-1">Следующее действие</h3>
<div class="relative group">
<div class="bg-surface-container-lowest p-8 rounded-xl shadow-[0_24px_48px_-12px_rgba(0,0,0,0.06)] flex flex-col gap-6 border-l-8 border-primary transition-transform hover:-translate-y-1 duration-300">
<div class="flex justify-between items-start">
<div class="flex gap-2">
<span class="px-3 py-1 bg-tertiary-container text-on-tertiary-container text-[10px] font-bold rounded-full uppercase tracking-tighter">P0</span>
<span class="px-3 py-1 bg-secondary-container text-on-secondary-container text-[10px] font-bold rounded-full uppercase tracking-tighter">Якорь</span>
</div>
<span class="material-symbols-outlined text-outline-variant" data-icon="more_horiz">more_horiz</span>
</div>
<div>
<h4 class="text-[2rem] font-bold leading-tight text-on-surface mb-2">Завершить отчет</h4>
<p class="text-body-lg text-on-surface-variant max-w-[80%]">Подготовка финальных графиков и проверка аналитики за квартал.</p>
</div>
<div class="flex justify-end">
<button class="bg-primary text-on-primary px-8 py-3 rounded-full font-bold shadow-lg shadow-primary/20 active:scale-95 transition-all">
                            Начать
                        </button>
</div>
</div>
</div>
</section>
<!-- Small Progress Section (Asymmetric Grid) -->
<section class="grid grid-cols-2 gap-4 mb-10">
<div class="bg-surface-container-low p-6 rounded-lg flex flex-col justify-between aspect-square">
<span class="material-symbols-outlined text-primary text-3xl" data-icon="task_alt">task_alt</span>
<div>
<div class="text-display-sm font-bold text-on-surface">8/12</div>
<div class="text-label-md text-on-surface-variant uppercase tracking-wider">Задач выполнено</div>
</div>
</div>
<div class="flex flex-col gap-4">
<div class="bg-secondary-container/40 p-5 rounded-lg flex-1 flex flex-col justify-between">
<div class="flex justify-between items-start">
<span class="material-symbols-outlined text-secondary" data-icon="timer">timer</span>
<span class="text-xs font-bold text-secondary">2ч 15м</span>
</div>
<span class="text-body-md font-medium text-on-secondary-container">Фокус сегодня</span>
</div>
<div class="bg-tertiary-container/10 p-5 rounded-lg flex-1 flex items-center gap-3">
<div class="w-2 h-2 rounded-full bg-tertiary animate-pulse"></div>
<span class="text-body-sm font-semibold text-tertiary">Нужна пауза</span>
</div>
</div>
</section>
</main>
<!-- FAB -->
<button class="fixed bottom-32 right-6 w-16 h-16 bg-gradient-to-br from-tertiary to-tertiary-dim text-on-tertiary rounded-full shadow-2xl flex items-center justify-center z-40 active:scale-90 transition-all group overflow-hidden">
<span class="material-symbols-outlined text-3xl group-hover:hidden" data-icon="sentiment_very_dissatisfied">sentiment_very_dissatisfied</span>
<span class="hidden group-hover:block text-[10px] font-bold uppercase px-2 leading-tight">Мне тяжело</span>
</button>
<!-- BottomNavBar from JSON -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 dark:bg-stone-900/80 backdrop-blur-2xl docked full-width bottom-0 rounded-t-[32px] no-border shadow-[0_-4px_24px_rgba(0,0,0,0.04)] shadow-2xl dark:shadow-none">
<!-- Item 1: Сегодня (Active) -->
<a class="flex flex-col items-center justify-center bg-green-100 dark:bg-green-900/40 text-green-800 dark:text-green-100 rounded-full px-6 py-2 active:scale-90 transition-all duration-200" href="#">
<span class="material-symbols-outlined" data-icon="wb_sunny" style="font-variation-settings: 'FILL' 1;">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Сегодня</span>
</a>
<!-- Item 2: Планы -->
<a class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300 transition-all duration-200" href="#">
<span class="material-symbols-outlined" data-icon="event_note">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Планы</span>
</a>
<!-- Item 3: Пульс -->
<a class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300 transition-all duration-200" href="#">
<span class="material-symbols-outlined" data-icon="Favorite">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Пульс</span>
</a>
<!-- Item 4: Архив -->
<a class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300 transition-all duration-200" href="#">
<span class="material-symbols-outlined" data-icon="history">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Архив</span>
</a>
</nav>
</body></html>

<!-- Dashboard (Главный экран) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-container-highest": "#dde4e0",
                        "on-secondary": "#fff8f0",
                        "primary-fixed": "#91f78e",
                        "on-secondary-fixed": "#523c00",
                        "secondary-fixed-dim": "#ffce5d",
                        "secondary": "#795a00",
                        "secondary-dim": "#6a4f00",
                        "on-surface-variant": "#59615d",
                        "on-tertiary-fixed": "#000000",
                        "on-tertiary-container": "#110000",
                        "surface-dim": "#d5dcd7",
                        "tertiary-fixed-dim": "#eb3c30",
                        "on-primary-container": "#005e17",
                        "primary": "#006f1d",
                        "error-container": "#fd795a",
                        "primary-container": "#91f78e",
                        "secondary-fixed": "#ffdf9e",
                        "on-error": "#fff7f6",
                        "on-primary-fixed": "#00480f",
                        "on-error-container": "#6e1400",
                        "background": "#f8faf7",
                        "on-tertiary": "#fff7f6",
                        "on-secondary-container": "#694d00",
                        "inverse-primary": "#91f78e",
                        "surface-bright": "#f8faf7",
                        "surface-container-high": "#e4e9e5",
                        "tertiary": "#bc1714",
                        "error": "#a73b21",
                        "on-tertiary-fixed-variant": "#340001",
                        "on-surface": "#2d3431",
                        "surface-tint": "#006f1d",
                        "outline-variant": "#acb4af",
                        "on-secondary-fixed-variant": "#755700",
                        "outline": "#757c79",
                        "secondary-container": "#ffdf9e",
                        "on-background": "#2d3431",
                        "primary-dim": "#006118",
                        "inverse-surface": "#0c0f0e",
                        "surface": "#f8faf7",
                        "surface-container-low": "#f1f5f1",
                        "surface-variant": "#dde4e0",
                        "tertiary-container": "#fd493b",
                        "surface-container": "#eaefeb",
                        "tertiary-dim": "#aa0208",
                        "on-primary": "#eaffe2",
                        "surface-container-lowest": "#ffffff",
                        "primary-fixed-dim": "#83e881",
                        "inverse-on-surface": "#9b9e9b",
                        "on-primary-fixed-variant": "#00691a",
                        "error-dim": "#791903",
                        "tertiary-fixed": "#fd493b"
                    },
                    "borderRadius": {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Inter"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .breathing-bg {
            background: radial-gradient(circle at 50% 50%, rgba(145, 247, 142, 0.08) 0%, rgba(248, 250, 247, 1) 70%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body min-h-screen relative overflow-hidden">
<!-- TopAppBar Shell -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 backdrop-blur-xl no-border bg-stone-100/50">
<div class="flex items-center gap-3">
<button class="w-10 h-10 rounded-full bg-surface-container-highest flex items-center justify-center hover:bg-stone-200/50 transition-colors Active: scale-95 transition-transform duration-300">
<span class="material-symbols-outlined text-on-surface">close</span>
</button>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-700">Мой день</h1>
</div>
<div class="flex items-center gap-4">
<span class="material-symbols-outlined text-green-700" data-icon="energy_savings_leaf">energy_savings_leaf</span>
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-high border-2 border-primary-container">
<img alt="User Profile" class="w-full h-full object-cover" data-alt="portrait of a calm professional woman in soft natural lighting, minimalist aesthetic, blurred green background" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCfmAVrQISsPW4_to7_0q4oLGWhBa7vM_-JK8A8Xj6KpfjOPr1ltgkQPM5s8NBRmkyfkAZYl_4ZW210ttX6v504N3hHMjckRLoOfn5QVfJ1wdUqFSY2TScThE73T12SCt5f1ot2egr34sldsiqqfeLVtYRv5dQPdilo--h2nERNu7s9gNUcyjqh19I7L3qnqv2wfW0CnR4EI585lazx932l-HiEDWNA5iEy7kqkzpxLJ_FfvtAiOromAhkDbqY2Gz6pZxxBnPGpEw"/>
</div>
</div>
</header>
<!-- Main Canvas: Focus Mode -->
<main class="relative z-10 flex flex-col items-center justify-center min-h-screen px-6 breathing-bg">
<!-- Center Focus Area -->
<div class="w-full max-w-2xl text-center flex flex-col items-center">
<!-- Energy/Priority Chip -->
<div class="mb-12 inline-flex items-center gap-2 px-6 py-2 rounded-full bg-primary-container text-on-primary-container font-medium text-sm tracking-wide">
<span class="material-symbols-outlined text-lg" style="font-variation-settings: 'FILL' 1;">anchor</span>
                P0 Якорь
            </div>
<!-- Task Display -->
<h2 class="font-headline text-[3.5rem] leading-[1.1] font-bold text-on-surface mb-6 tracking-tight max-w-xl">
                Подготовить презентацию
            </h2>
<p class="font-body text-xl text-on-surface-variant mb-16 max-w-lg leading-relaxed opacity-80">
                Только первый черновик, без оформления.
            </p>
<!-- Primary Action -->
<button class="group relative px-12 py-5 bg-gradient-to-r from-primary to-primary-dim text-on-primary rounded-full font-bold text-xl shadow-2xl hover:scale-105 active:scale-95 transition-all duration-300">
                Поехали
                <span class="absolute inset-0 rounded-full bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity"></span>
</button>
</div>
<!-- Decorative Elements for "Living Sanctuary" -->
<div class="absolute top-1/4 -left-20 w-96 h-96 bg-primary-container/10 blur-[100px] rounded-full"></div>
<div class="absolute bottom-1/4 -right-20 w-80 h-80 bg-secondary-container/10 blur-[100px] rounded-full"></div>
</main>
<!-- Contextual FAB: "Мне тяжело" (Low Energy State Trigger) -->
<button class="fixed bottom-12 right-8 z-[60] flex items-center gap-3 pl-4 pr-6 py-4 bg-tertiary text-on-tertiary rounded-full shadow-2xl hover:bg-tertiary-dim active:scale-90 transition-all duration-200">
<span class="material-symbols-outlined" data-icon="sentiment_dissatisfied" style="font-variation-settings: 'FILL' 1;">sentiment_dissatisfied</span>
<span class="font-bold text-sm uppercase tracking-wider">Мне тяжело</span>
</button>
<!-- BottomNavBar Suppressed (Transactional/Focus Mode) -->
<!-- According to Shell Visibility & Relevance: Hide shell for focused task-journey -->
</body></html>

<!-- Focus Mode (Режим фокуса) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-highest": "#dde4e0",
                    "on-secondary": "#fff8f0",
                    "primary-fixed": "#91f78e",
                    "on-secondary-fixed": "#523c00",
                    "secondary-fixed-dim": "#ffce5d",
                    "secondary": "#795a00",
                    "secondary-dim": "#6a4f00",
                    "on-surface-variant": "#59615d",
                    "on-tertiary-fixed": "#000000",
                    "on-tertiary-container": "#110000",
                    "surface-dim": "#d5dcd7",
                    "tertiary-fixed-dim": "#eb3c30",
                    "on-primary-container": "#005e17",
                    "primary": "#006f1d",
                    "error-container": "#fd795a",
                    "primary-container": "#91f78e",
                    "secondary-fixed": "#ffdf9e",
                    "on-error": "#fff7f6",
                    "on-primary-fixed": "#00480f",
                    "on-error-container": "#6e1400",
                    "background": "#f8faf7",
                    "on-tertiary": "#fff7f6",
                    "on-secondary-container": "#694d00",
                    "inverse-primary": "#91f78e",
                    "surface-bright": "#f8faf7",
                    "surface-container-high": "#e4e9e5",
                    "tertiary": "#bc1714",
                    "error": "#a73b21",
                    "on-tertiary-fixed-variant": "#340001",
                    "on-surface": "#2d3431",
                    "surface-tint": "#006f1d",
                    "outline-variant": "#acb4af",
                    "on-secondary-fixed-variant": "#755700",
                    "outline": "#757c79",
                    "secondary-container": "#ffdf9e",
                    "on-background": "#2d3431",
                    "primary-dim": "#006118",
                    "inverse-surface": "#0c0f0e",
                    "surface": "#f8faf7",
                    "surface-container-low": "#f1f5f1",
                    "surface-variant": "#dde4e0",
                    "tertiary-container": "#fd493b",
                    "surface-container": "#eaefeb",
                    "tertiary-dim": "#aa0208",
                    "on-primary": "#eaffe2",
                    "surface-container-lowest": "#ffffff",
                    "primary-fixed-dim": "#83e881",
                    "inverse-on-surface": "#9b9e9b",
                    "on-primary-fixed-variant": "#00691a",
                    "error-dim": "#791903",
                    "tertiary-fixed": "#fd493b"
            },
            "borderRadius": {
                    "DEFAULT": "1rem",
                    "lg": "2rem",
                    "xl": "3rem",
                    "full": "9999px"
            },
            "fontFamily": {
                    "headline": ["Inter"],
                    "body": ["Inter"],
                    "label": ["Inter"]
            }
          }
        }
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; -webkit-font-smoothing: antialiased; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .energy-gradient {
            background: radial-gradient(circle at center, rgba(145, 247, 142, 0.08) 0%, rgba(248, 250, 247, 0) 70%);
        }
        .timer-glow {
            box-shadow: 0 0 80px rgba(0, 111, 29, 0.05);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface min-h-screen flex flex-col overflow-hidden">
<!-- Top Navigation Shell - As per JSON hierarchy -->
<!-- Suppressed for transactional/focused screen: "Task in progress" Focus Session -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 dark:bg-stone-900/60 backdrop-blur-xl">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden">
<img alt="User Profile" class="w-full h-full object-cover" data-alt="Close up portrait of a calm smiling woman with soft natural lighting and neutral background" src="https://lh3.googleusercontent.com/aida-public/AB6AXuA7mb9qTSIBx6RZgAq9EUU-qMu4NFXOFCG5GEVj4G88GV1FEoDuTnm12VzQe2Qdch5xVFJRQNsBvpRaHQwIsMnef8ytlvbLMQzJFoB1aI6YOhAehRfqxvKYxc-htFCP_bn19cMgyfkyieLGgEUl1b_xdoseHwRIqJ7t11hl5h4TItVEJyGpjD9bEoptxvGdhEr1v9CY1SHCkT-5rM1eRGeOjJGGqBRvW_lQ51BlBL8L-mIRAxKHN-yZ79d5ZuXXevlQJHA8UOBNDw"/>
</div>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-700 dark:text-green-400">Мой день</h1>
</div>
<div class="p-2 rounded-full hover:bg-stone-200/50 transition-colors cursor-pointer">
<span class="material-symbols-outlined text-green-700 dark:text-green-400">energy_savings_leaf</span>
</div>
</header>
<!-- Main Content Canvas -->
<main class="flex-1 flex flex-col items-center justify-center relative px-6 pt-20 pb-32 energy-gradient">
<!-- Energy Pulse Background Element -->
<div class="absolute inset-0 pointer-events-none flex items-center justify-center">
<div class="w-[500px] h-[500px] bg-primary/5 rounded-full blur-[100px]"></div>
</div>
<!-- Task Info Section -->
<div class="text-center mb-12 z-10">
<span class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary-container/30 text-on-primary-container text-[12px] font-medium tracking-wider uppercase mb-4">
<span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
                В процессе
            </span>
<h2 class="text-3xl md:text-4xl font-bold text-on-surface tracking-tight mb-2">Подготовить презентацию</h2>
<p class="text-on-surface-variant max-w-xs mx-auto">Создаем атмосферу фокуса для вашей лучшей работы</p>
</div>
<!-- Timer Circle: The Living Sanctuary Core -->
<div class="relative w-72 h-72 md:w-80 md:h-80 flex items-center justify-center z-10">
<!-- Pulsing outer rings -->
<div class="absolute inset-0 border-2 border-primary/10 rounded-full scale-110"></div>
<div class="absolute inset-0 border-[1px] border-primary/5 rounded-full scale-125"></div>
<!-- Main Timer Container -->
<div class="w-full h-full rounded-full bg-surface-container-lowest timer-glow flex flex-col items-center justify-center relative overflow-hidden">
<!-- Visual Progress Fill (Subtle) -->
<div class="absolute bottom-0 left-0 w-full bg-primary/5 h-[40%]"></div>
<span class="font-headline text-7xl md:text-8xl font-bold tracking-tighter text-on-surface relative">
                    24:59
                </span>
<div class="flex items-center gap-1 mt-2 text-on-surface-variant font-medium relative">
<span class="material-symbols-outlined text-[18px]">timer</span>
<span class="text-sm">минуты</span>
</div>
</div>
</div>
<!-- Action Controls -->
<div class="mt-16 flex flex-row items-center gap-4 z-10 w-full max-w-sm">
<button class="flex-1 py-4 px-6 rounded-full bg-surface-container-highest text-on-surface font-semibold text-lg hover:scale-95 transition-all duration-300">
                Пауза
            </button>
<button class="flex-[1.5] py-4 px-6 rounded-full bg-primary text-on-primary font-semibold text-lg shadow-lg shadow-primary/20 hover:scale-95 transition-all duration-300">
                Готово
            </button>
</div>
<!-- Floating Action Button (Contextual) -->
<!-- Requirement: Red FAB 'Мне тяжело' visible -->
<div class="fixed right-6 bottom-10 z-50">
<button class="group flex items-center gap-3 px-6 py-4 bg-tertiary text-on-tertiary rounded-full shadow-2xl transition-all duration-300 active:scale-90">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">favorite</span>
<span class="font-semibold tracking-wide">Мне тяжело</span>
</button>
</div>
</main>
<!-- Bottom Navigation Shell - Excluded for Task-Focused focus mode per "Shell Visibility & Relevance" rule -->
<!-- The user is in a focused journey (Timer), suppressing global nav to prioritize content canvas. -->
<!-- Ambient Mood Background Layer -->
<div class="fixed inset-0 -z-10 bg-surface">
<div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary-container/10 rounded-full blur-[120px]"></div>
<div class="absolute bottom-[-5%] right-[-5%] w-[30%] h-[30%] bg-secondary-container/10 rounded-full blur-[100px]"></div>
</div>
</body></html>

<!-- Focus Session (Таймер) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-container-highest": "#dde4e0",
                        "on-secondary": "#fff8f0",
                        "primary-fixed": "#91f78e",
                        "on-secondary-fixed": "#523c00",
                        "secondary-fixed-dim": "#ffce5d",
                        "secondary": "#795a00",
                        "secondary-dim": "#6a4f00",
                        "on-surface-variant": "#59615d",
                        "on-tertiary-fixed": "#000000",
                        "on-tertiary-container": "#110000",
                        "surface-dim": "#d5dcd7",
                        "tertiary-fixed-dim": "#eb3c30",
                        "on-primary-container": "#005e17",
                        "primary": "#006f1d",
                        "error-container": "#fd795a",
                        "primary-container": "#91f78e",
                        "secondary-fixed": "#ffdf9e",
                        "on-error": "#fff7f6",
                        "on-primary-fixed": "#00480f",
                        "on-error-container": "#6e1400",
                        "background": "#f8faf7",
                        "on-tertiary": "#fff7f6",
                        "on-secondary-container": "#694d00",
                        "inverse-primary": "#91f78e",
                        "surface-bright": "#f8faf7",
                        "surface-container-high": "#e4e9e5",
                        "tertiary": "#bc1714",
                        "error": "#a73b21",
                        "on-tertiary-fixed-variant": "#340001",
                        "on-surface": "#2d3431",
                        "surface-tint": "#006f1d",
                        "outline-variant": "#acb4af",
                        "on-secondary-fixed-variant": "#755700",
                        "outline": "#757c79",
                        "secondary-container": "#ffdf9e",
                        "on-background": "#2d3431",
                        "primary-dim": "#006118",
                        "inverse-surface": "#0c0f0e",
                        "surface": "#f8faf7",
                        "surface-container-low": "#f1f5f1",
                        "surface-variant": "#dde4e0",
                        "tertiary-container": "#fd493b",
                        "surface-container": "#eaefeb",
                        "tertiary-dim": "#aa0208",
                        "on-primary": "#eaffe2",
                        "surface-container-lowest": "#ffffff",
                        "primary-fixed-dim": "#83e881",
                        "inverse-on-surface": "#9b9e9b",
                        "on-primary-fixed-variant": "#00691a",
                        "error-dim": "#791903",
                        "tertiary-fixed": "#fd493b"
                    },
                    "borderRadius": {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Inter"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        body {
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at 50% 50%, #f8faf7 0%, #f1f5f1 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-surface min-h-screen flex flex-col overflow-x-hidden">
<!-- Shell Suppression: Completion screen is focused/transactional, TopAppBar and BottomNavBar are hidden to focus on the achievement -->
<main class="flex-grow flex flex-col items-center justify-center px-6 relative py-12">
<!-- Breathing Background Layer -->
<div class="absolute inset-0 z-0 opacity-20 pointer-events-none overflow-hidden">
<div class="absolute top-1/4 left-1/4 w-[500px] h-[500px] bg-tertiary-container rounded-full blur-[120px] mix-blend-soft-light"></div>
<div class="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-primary-container rounded-full blur-[120px] mix-blend-soft-light"></div>
</div>
<!-- Success Content Container -->
<div class="z-10 w-full max-w-md flex flex-col items-center text-center">
<!-- Confetti Illustration -->
<div class="relative w-64 h-64 mb-10 flex items-center justify-center">
<div class="absolute inset-0 bg-surface-container-lowest rounded-full opacity-40 blur-2xl"></div>
<div class="relative z-10 grid grid-cols-3 gap-4 items-center justify-center">
<span class="material-symbols-outlined text-primary scale-[2] rotate-12" style="font-variation-settings: 'FILL' 1;">spa</span>
<span class="material-symbols-outlined text-tertiary scale-[1.5] -rotate-12" style="font-variation-settings: 'FILL' 1;">favorite</span>
<span class="material-symbols-outlined text-secondary scale-[2.5]" style="font-variation-settings: 'FILL' 1;">energy_savings_leaf</span>
<span class="material-symbols-outlined text-tertiary scale-[1.8] translate-x-4" style="font-variation-settings: 'FILL' 1;">celebration</span>
<span class="material-symbols-outlined text-primary scale-[3]" style="font-variation-settings: 'FILL' 1;">task_alt</span>
<span class="material-symbols-outlined text-secondary scale-[1.5] -translate-x-4" style="font-variation-settings: 'FILL' 1;">stars</span>
</div>
<!-- Abstract Confetti Elements -->
<div class="absolute top-4 right-10 w-3 h-3 rounded-full bg-primary-container"></div>
<div class="absolute bottom-10 left-8 w-4 h-4 rounded-lg rotate-45 bg-tertiary-container opacity-60"></div>
<div class="absolute top-20 left-4 w-2 h-2 rounded-full bg-secondary-container"></div>
<div class="absolute top-10 left-1/2 -translate-x-1/2 w-6 h-1 rounded-full bg-primary/20 rotate-12"></div>
</div>
<!-- Editorial Header -->
<h1 class="text-[3.5rem] font-bold leading-[1.1] tracking-tighter text-on-surface mb-4">
                Ты сделал <br/>
<span class="text-tertiary">шаг.</span>
</h1>
<p class="text-on-surface-variant text-lg leading-relaxed mb-12 px-4">
                Эта задача была важна. Теперь прислушайся к себе: сколько сил осталось на продолжение?
            </p>
<!-- Energy Insight Card -->
<div class="w-full bg-surface-container-low rounded-lg p-6 mb-12 flex items-center gap-5 text-left border border-outline-variant/10">
<div class="w-12 h-12 rounded-full bg-tertiary-container/30 flex items-center justify-center text-tertiary">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">battery_low</span>
</div>
<div>
<div class="text-[11px] font-medium tracking-wide uppercase text-tertiary-dim mb-1">Состояние: Низкая энергия</div>
<div class="text-on-surface font-medium">Рекомендуем небольшую паузу</div>
</div>
</div>
<!-- Adaptive Buttons Stack -->
<div class="w-full flex flex-col gap-4">
<!-- Large Primary Action (Rest - Low Energy Priority) -->
<button class="w-full py-6 px-8 rounded-full bg-gradient-to-r from-tertiary to-tertiary-dim text-on-tertiary font-bold text-xl shadow-[0_24px_24px_-4px_rgba(188,23,20,0.12)] hover:scale-[0.98] transition-all flex items-center justify-center gap-3">
<span class="material-symbols-outlined">coffee</span>
                    Отдохнуть
                </button>
<!-- Small Secondary Action -->
<button class="w-full py-4 px-8 rounded-full bg-surface-container-highest text-on-surface font-semibold text-base hover:bg-surface-variant transition-colors flex items-center justify-center gap-2">
                    Следующая задача
                    <span class="material-symbols-outlined text-sm">arrow_forward</span>
</button>
</div>
</div>
<!-- Supportive Insight Footer -->
<div class="mt-16 text-center max-w-[280px]">
<p class="text-sm italic text-on-surface-variant/70 leading-relaxed">
                "Отдых — это не отсутствие действий, а восстановление ресурса."
            </p>
</div>
</main>
<!-- Contextual FAB Suppression: Not appropriate for completion/transactional success screens -->
</body></html>

<!-- Completion Screen (Экран успеха) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-highest": "#dde4e0",
                    "on-secondary": "#fff8f0",
                    "primary-fixed": "#91f78e",
                    "on-secondary-fixed": "#523c00",
                    "secondary-fixed-dim": "#ffce5d",
                    "secondary": "#795a00",
                    "secondary-dim": "#6a4f00",
                    "on-surface-variant": "#59615d",
                    "on-tertiary-fixed": "#000000",
                    "on-tertiary-container": "#110000",
                    "surface-dim": "#d5dcd7",
                    "tertiary-fixed-dim": "#eb3c30",
                    "on-primary-container": "#005e17",
                    "primary": "#006f1d",
                    "error-container": "#fd795a",
                    "primary-container": "#91f78e",
                    "secondary-fixed": "#ffdf9e",
                    "on-error": "#fff7f6",
                    "on-primary-fixed": "#00480f",
                    "on-error-container": "#6e1400",
                    "background": "#f8faf7",
                    "on-tertiary": "#fff7f6",
                    "on-secondary-container": "#694d00",
                    "inverse-primary": "#91f78e",
                    "surface-bright": "#f8faf7",
                    "surface-container-high": "#e4e9e5",
                    "tertiary": "#bc1714",
                    "error": "#a73b21",
                    "on-tertiary-fixed-variant": "#340001",
                    "on-surface": "#2d3431",
                    "surface-tint": "#006f1d",
                    "outline-variant": "#acb4af",
                    "on-secondary-fixed-variant": "#755700",
                    "outline": "#757c79",
                    "secondary-container": "#ffdf9e",
                    "on-background": "#2d3431",
                    "primary-dim": "#006118",
                    "inverse-surface": "#0c0f0e",
                    "surface": "#f8faf7",
                    "surface-container-low": "#f1f5f1",
                    "surface-variant": "#dde4e0",
                    "tertiary-container": "#fd493b",
                    "surface-container": "#eaefeb",
                    "tertiary-dim": "#aa0208",
                    "on-primary": "#eaffe2",
                    "surface-container-lowest": "#ffffff",
                    "primary-fixed-dim": "#83e881",
                    "inverse-on-surface": "#9b9e9b",
                    "on-primary-fixed-variant": "#00691a",
                    "error-dim": "#791903",
                    "tertiary-fixed": "#fd493b"
            },
            "borderRadius": {
                    "DEFAULT": "1rem",
                    "lg": "2rem",
                    "xl": "3rem",
                    "full": "9999px"
            },
            "fontFamily": {
                    "headline": ["Inter"],
                    "body": ["Inter"],
                    "label": ["Inter"]
            }
          },
        }
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; -webkit-font-smoothing: antialiased; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; vertical-align: middle; }
        .breathing-bg {
            background: radial-gradient(circle at 50% 50%, rgba(145, 247, 142, 0.05) 0%, rgba(248, 250, 247, 1) 100%);
        }
        .editorial-shadow { box-shadow: 0 24px 48px -12px rgba(45, 52, 49, 0.06); }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background min-h-screen pb-32 breathing-bg">
<!-- TopAppBar -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 dark:bg-stone-900/60 backdrop-blur-xl no-border bg-stone-100/50">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-highest">
<img alt="User Profile" class="w-full h-full object-cover" data-alt="Close-up portrait of a serene young woman with natural light, calm expression, soft focus garden background" src="https://lh3.googleusercontent.com/aida-public/AB6AXuABbBeWOzyMahWUdu6QwEI1o8w1AZuuVt-2DcUcsAnWBKTz4gQfMJtL0xbOz23zfKYnmRkfIkEXTKUtr8beJtyZ03jCN0WCMICvy8nhXx6w_8iBi3d59EvwUxdgWyuXqpOjP9WIYI6CBuSdqINCWt2u9gW2ZMMG9mThAcbuM6Kck1j5NoVEN-jmaUZTzONPYs5Pb4zn_F0m-Zx6uaiMR4NIVfCBewxnx4SFYzG0zDPGJdiphNPhGszVX2CWi1ozUTc3m07q5-MSFQ"/>
</div>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-700">Мой день</h1>
</div>
<div class="flex items-center gap-2">
<button class="p-2 rounded-full hover:bg-stone-200/50 transition-colors active:scale-95 duration-300">
<span class="material-symbols-outlined text-green-700">energy_savings_leaf</span>
</button>
</div>
</header>
<main class="pt-24 px-6 max-w-5xl mx-auto">
<!-- Energy Status Display -->
<section class="mb-12">
<div class="flex flex-col md:flex-row md:items-end justify-between gap-6">
<div>
<span class="text-label-md font-medium text-on-surface-variant uppercase tracking-[0.2em] mb-2 block">Ваше состояние</span>
<h2 class="text-5xl md:text-7xl font-bold text-primary tracking-tighter leading-none">Полон сил</h2>
</div>
<div class="flex flex-wrap gap-3">
<span class="px-4 py-2 bg-primary-container text-on-primary-container rounded-full text-sm font-medium flex items-center gap-2">
<span class="material-symbols-outlined text-[18px]" style="font-variation-settings: 'FILL' 1;">bolt</span> 85% энергии
                    </span>
<span class="px-4 py-2 bg-surface-container-high text-on-surface rounded-full text-sm font-medium">12 задач</span>
</div>
</div>
</section>
<!-- Phase Filter Chips -->
<nav class="flex gap-4 mb-10 overflow-x-auto pb-2 no-scrollbar">
<button class="px-8 py-3 bg-primary text-on-primary rounded-full font-semibold text-sm shadow-lg shadow-primary/20 transition-transform active:scale-95">Все</button>
<button class="px-8 py-3 bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high rounded-full font-medium text-sm transition-colors">Утро</button>
<button class="px-8 py-3 bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high rounded-full font-medium text-sm transition-colors">День</button>
<button class="px-8 py-3 bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high rounded-full font-medium text-sm transition-colors">Вечер</button>
</nav>
<!-- Task Bento Grid -->
<div class="grid grid-cols-1 md:grid-cols-12 gap-6">
<!-- Anchor Task (P0) - Priority focus -->
<div class="md:col-span-8 bg-surface-container-lowest rounded-lg p-8 editorial-shadow relative overflow-hidden group">
<div class="absolute top-0 right-0 p-6">
<span class="px-3 py-1 bg-primary/10 text-primary rounded-full text-[10px] font-bold uppercase tracking-widest">Якорь P0</span>
</div>
<div class="flex flex-col h-full justify-between gap-8">
<div>
<div class="w-12 h-12 bg-primary-container rounded-xl flex items-center justify-center mb-6">
<span class="material-symbols-outlined text-on-primary-container">architecture</span>
</div>
<h3 class="text-3xl font-bold text-on-surface mb-3 leading-tight">Финальный ревью проекта <br/> "Living Sanctuary"</h3>
<p class="text-on-surface-variant max-w-md leading-relaxed">Критически важная задача на сегодня. Требует максимальной концентрации и свежего взгляда.</p>
</div>
<div class="flex items-center gap-4">
<button class="bg-primary text-on-primary px-6 py-3 rounded-full font-bold text-sm hover:opacity-90 transition-opacity">Начать сейчас</button>
<span class="text-on-surface-variant text-sm flex items-center gap-2">
<span class="material-symbols-outlined text-sm">schedule</span> 10:00 - 11:30
                        </span>
</div>
</div>
</div>
<!-- Energy Insight Card -->
<div class="md:col-span-4 bg-primary-container/30 rounded-lg p-8 flex flex-col justify-between border border-primary/5">
<h4 class="text-xl font-semibold text-on-primary-container">Совет дня</h4>
<p class="text-on-primary-container/80 text-sm leading-relaxed mt-4 italic">"Ваша продуктивность сегодня на пике до 14:00. Используйте это время для задач категории P0 и P1."</p>
<div class="mt-8 pt-6 border-t border-primary/10">
<div class="flex items-center gap-3">
<span class="material-symbols-outlined text-primary">eco</span>
<span class="text-xs font-bold text-primary uppercase">Рост и фокус</span>
</div>
</div>
</div>
<!-- Task List (P1 & P2) -->
<div class="md:col-span-6 space-y-4">
<h4 class="text-label-md font-bold text-on-surface-variant uppercase tracking-widest px-2 mb-4">Основные цели (P1)</h4>
<div class="bg-surface-container-low hover:bg-surface-container-lowest transition-all duration-300 rounded-lg p-5 flex items-center justify-between group">
<div class="flex items-center gap-4">
<div class="w-2 h-2 rounded-full bg-secondary"></div>
<div>
<h5 class="font-semibold text-on-surface">Подготовка презентации</h5>
<span class="text-xs text-on-surface-variant">45 минут • Цель</span>
</div>
</div>
<span class="material-symbols-outlined text-outline-variant group-hover:text-primary transition-colors">check_circle</span>
</div>
<div class="bg-surface-container-low hover:bg-surface-container-lowest transition-all duration-300 rounded-lg p-5 flex items-center justify-between group">
<div class="flex items-center gap-4">
<div class="w-2 h-2 rounded-full bg-secondary"></div>
<div>
<h5 class="font-semibold text-on-surface">Встреча с командой дизайна</h5>
<span class="text-xs text-on-surface-variant">1 час • Цель</span>
</div>
</div>
<span class="material-symbols-outlined text-outline-variant group-hover:text-primary transition-colors">check_circle</span>
</div>
</div>
<div class="md:col-span-6 space-y-4">
<h4 class="text-label-md font-bold text-on-surface-variant uppercase tracking-widest px-2 mb-4">Бонус (P2)</h4>
<div class="bg-surface-container-low hover:bg-surface-container-lowest transition-all duration-300 rounded-lg p-5 flex items-center justify-between group">
<div class="flex items-center gap-4 opacity-70">
<div class="w-2 h-2 rounded-full bg-outline"></div>
<div>
<h5 class="font-semibold text-on-surface">Чтение проф. литературы</h5>
<span class="text-xs text-on-surface-variant">20 минут • Бонус</span>
</div>
</div>
<span class="material-symbols-outlined text-outline-variant">radio_button_unchecked</span>
</div>
<!-- Locked Task Example -->
<div class="bg-surface-container-low/40 rounded-lg p-5 flex items-center justify-between relative overflow-hidden group">
<div class="flex items-center gap-4 opacity-30 blur-[1px]">
<div class="w-2 h-2 rounded-full bg-outline"></div>
<div>
<h5 class="font-semibold text-on-surface">Изучение нового фреймворка</h5>
<span class="text-xs text-on-surface-variant">Потребуется больше энергии</span>
</div>
</div>
<div class="absolute inset-0 flex items-center justify-center bg-background/50 opacity-0 group-hover:opacity-100 transition-opacity">
<span class="material-symbols-outlined text-tertiary">lock_open</span>
<span class="ml-2 text-xs font-bold text-tertiary uppercase">Низкая энергия</span>
</div>
<span class="material-symbols-outlined text-outline-variant/40">lock</span>
</div>
</div>
</div>
</main>
<!-- FAB: Мне тяжело -->
<button class="fixed bottom-32 right-6 z-50 flex items-center gap-3 bg-tertiary text-on-tertiary pl-6 pr-8 py-4 rounded-full shadow-2xl shadow-tertiary/40 active:scale-90 transition-all hover:brightness-110">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">heart_broken</span>
<span class="font-bold text-sm uppercase tracking-wider">Мне тяжело</span>
</button>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 dark:bg-stone-900/80 backdrop-blur-2xl no-border shadow-[0_-4px_24px_rgba(0,0,0,0.04)] shadow-2xl rounded-t-[32px]">
<a class="flex flex-col items-center justify-center bg-green-100 text-green-800 rounded-full px-6 py-2 transition-all duration-200" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Сегодня</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Планы</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Пульс</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Архив</span>
</a>
</nav>
</body></html>

<!-- Overview (Обзор задач) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-container-highest": "#dde4e0",
                        "on-secondary": "#fff8f0",
                        "primary-fixed": "#91f78e",
                        "on-secondary-fixed": "#523c00",
                        "secondary-fixed-dim": "#ffce5d",
                        "secondary": "#795a00",
                        "secondary-dim": "#6a4f00",
                        "on-surface-variant": "#59615d",
                        "on-tertiary-fixed": "#000000",
                        "on-tertiary-container": "#110000",
                        "surface-dim": "#d5dcd7",
                        "tertiary-fixed-dim": "#eb3c30",
                        "on-primary-container": "#005e17",
                        "primary": "#006f1d",
                        "error-container": "#fd795a",
                        "primary-container": "#91f78e",
                        "secondary-fixed": "#ffdf9e",
                        "on-error": "#fff7f6",
                        "on-primary-fixed": "#00480f",
                        "on-error-container": "#6e1400",
                        "background": "#f8faf7",
                        "on-tertiary": "#fff7f6",
                        "on-secondary-container": "#694d00",
                        "inverse-primary": "#91f78e",
                        "surface-bright": "#f8faf7",
                        "surface-container-high": "#e4e9e5",
                        "tertiary": "#bc1714",
                        "error": "#a73b21",
                        "on-tertiary-fixed-variant": "#340001",
                        "on-surface": "#2d3431",
                        "surface-tint": "#006f1d",
                        "outline-variant": "#acb4af",
                        "on-secondary-fixed-variant": "#755700",
                        "outline": "#757c79",
                        "secondary-container": "#ffdf9e",
                        "on-background": "#2d3431",
                        "primary-dim": "#006118",
                        "inverse-surface": "#0c0f0e",
                        "surface": "#f8faf7",
                        "surface-container-low": "#f1f5f1",
                        "surface-variant": "#dde4e0",
                        "tertiary-container": "#fd493b",
                        "surface-container": "#eaefeb",
                        "tertiary-dim": "#aa0208",
                        "on-primary": "#eaffe2",
                        "surface-container-lowest": "#ffffff",
                        "primary-fixed-dim": "#83e881",
                        "inverse-on-surface": "#9b9e9b",
                        "on-primary-fixed-variant": "#00691a",
                        "error-dim": "#791903",
                        "tertiary-fixed": "#fd493b"
                    },
                    "borderRadius": {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Inter"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .breathing-bg {
            background: radial-gradient(circle at 50% 50%, rgba(145, 247, 142, 0.05) 0%, rgba(248, 250, 247, 1) 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface font-body text-on-surface selection:bg-primary-container selection:text-on-primary-container min-h-screen flex flex-col breathing-bg">
<nav class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 backdrop-blur-xl no-border bg-stone-100/50">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-high">
<img alt="User Profile" class="w-full h-full object-cover" data-alt="Close-up portrait of a serene woman with a soft smile in natural outdoor lighting, peaceful and focused mood" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCkaGL532U4a_W-F16up2Zy72cA7BiP_QvcZcxP4HpsSU2WRs8ouEp__UfpMEPfrjCPW4h4Gk5b6IIOCvkNCHD7HzNUt5NeJnclQm64ZGP7MhfwkSoCNjZaOOkY6qj8RkFbc0z-bEdsyob3Cpuv9z9mvZRFBj9O6GBmahZIutG73hhW0f70sXBCVdg52vRkbKWPtdCQDtSa3Ju2DkYrE5ipi_GT0V6hyoELh5lRgsx9KTa0JYNPyX77OjEUfH4CrEELVPNT8lbx1w"/>
</div>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-700">Мой день</h1>
</div>
<button class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-stone-200/50 transition-colors Active: scale-95 transition-transform duration-300">
<span class="material-symbols-outlined text-green-700" data-icon="energy_savings_leaf">energy_savings_leaf</span>
</button>
</nav>
<main class="flex-grow pt-32 pb-40 px-6 max-w-4xl mx-auto w-full flex flex-col">
<section class="mb-12">
<div class="inline-flex items-center px-4 py-1.5 rounded-full bg-secondary-container text-on-secondary-container text-[11px] font-medium tracking-wide uppercase mb-6">
                Мягкий старт
            </div>
<h2 class="text-[3.5rem] leading-[1.1] font-bold tracking-tight text-on-surface mb-8 max-w-2xl ml-4 md:ml-8">
                Тяжело начать?
            </h2>
<p class="text-lg text-on-surface-variant leading-relaxed max-w-lg ml-4 md:ml-8">
                Это нормально — иногда задачи кажутся горой. Давай разберемся, что именно сейчас мешает тебе сделать первый шаг.
            </p>
</section>
<div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">
<div class="space-y-4 md:space-y-6">
<button class="w-full text-left p-8 rounded-lg bg-surface-container-low hover:bg-surface-container-highest transition-all group flex flex-col gap-4">
<div class="w-12 h-12 rounded-full bg-primary-container flex items-center justify-center text-on-primary-container group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined" data-icon="architecture">architecture</span>
</div>
<div>
<h3 class="text-xl font-medium mb-1">Да, слишком большая</h3>
<p class="text-sm text-on-surface-variant leading-relaxed">Попробуем разбить её на крошечные, понятные кусочки.</p>
</div>
</button>
<button class="w-full text-left p-8 rounded-lg bg-surface-container-low hover:bg-surface-container-highest transition-all group flex flex-col gap-4">
<div class="w-12 h-12 rounded-full bg-tertiary-container flex items-center justify-center text-on-tertiary-container group-hover:scale-110 transition-transform">
<span class="material-symbols-outlined" data-icon="battery_low">battery_low</span>
</div>
<div>
<h3 class="text-xl font-medium mb-1">Да, нет сил</h3>
<p class="text-sm text-on-surface-variant leading-relaxed">Может, стоит начать с 5-минутного отдыха или легкой разминки?</p>
</div>
</button>
<button class="w-full p-8 rounded-lg bg-primary text-on-primary hover:bg-primary-dim transition-all shadow-lg flex items-center justify-between group">
<div class="flex flex-col gap-1">
<h3 class="text-xl font-bold">Нет, поехали</h3>
<p class="text-sm opacity-80">Я готов взяться за дело прямо сейчас</p>
</div>
<span class="material-symbols-outlined text-3xl group-hover:translate-x-2 transition-transform" data-icon="arrow_forward">arrow_forward</span>
</button>
</div>
<div class="hidden md:block sticky top-32">
<div class="rounded-lg overflow-hidden bg-surface-container-low aspect-square relative">
<img alt="Serene Landscape" class="w-full h-full object-cover mix-blend-overlay opacity-80" data-alt="Quiet misty morning in a minimalist forest, soft diffused light, calm atmosphere with a sense of clarity" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDS-cHa47X4F2vZdR_HQGSpvaQETtPSgryLC8wHyXIik88aymuxvOCNU4Itezy-VZozy9pTaphuzcy90mChxRoFodjsUnNG7CKVrxxIYvyII4Kt_CmMLW7kr0EytqGp9eJ9Wtzo_JVsSjKuS5kbjsw9ndnSx1PXnVjGVwSnTRk6uxShNHtNuxAho5t5traHkFwiyjt5uwm-RIxIV__zLeyXhRGtoyvLgG0N5jEoCECpxJlbj-7Pv_b-e52mQIgPFYCmrTRcUTOYsg"/>
<div class="absolute inset-0 p-10 flex flex-col justify-end bg-gradient-to-t from-surface-container-low/80 to-transparent">
<span class="text-sm font-medium text-secondary mb-2">Совет дня</span>
<blockquote class="text-xl font-medium italic text-on-surface">
                            «Мастерство начинается с решения просто попробовать».
                        </blockquote>
</div>
</div>
</div>
</div>
</main>
<footer class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 backdrop-blur-2xl no-border shadow-2xl">
<a class="flex flex-col items-center justify-center bg-green-100 text-green-800 rounded-full px-6 py-2" href="#">
<span class="material-symbols-outlined" data-icon="wb_sunny">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Сегодня</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined" data-icon="event_note">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Планы</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined" data-icon="Favorite">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Пульс</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined" data-icon="history">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Архив</span>
</a>
</footer>
</body></html>

<!-- Задача с ветками (Интерактив) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-highest": "#dde4e0",
                    "on-secondary": "#fff8f0",
                    "primary-fixed": "#91f78e",
                    "on-secondary-fixed": "#523c00",
                    "secondary-fixed-dim": "#ffce5d",
                    "secondary": "#795a00",
                    "secondary-dim": "#6a4f00",
                    "on-surface-variant": "#59615d",
                    "on-tertiary-fixed": "#000000",
                    "on-tertiary-container": "#110000",
                    "surface-dim": "#d5dcd7",
                    "tertiary-fixed-dim": "#eb3c30",
                    "on-primary-container": "#005e17",
                    "primary": "#006f1d",
                    "error-container": "#fd795a",
                    "primary-container": "#91f78e",
                    "secondary-fixed": "#ffdf9e",
                    "on-error": "#fff7f6",
                    "on-primary-fixed": "#00480f",
                    "on-error-container": "#6e1400",
                    "background": "#f8faf7",
                    "on-tertiary": "#fff7f6",
                    "on-secondary-container": "#694d00",
                    "inverse-primary": "#91f78e",
                    "surface-bright": "#f8faf7",
                    "surface-container-high": "#e4e9e5",
                    "tertiary": "#bc1714",
                    "error": "#a73b21",
                    "on-tertiary-fixed-variant": "#340001",
                    "on-surface": "#2d3431",
                    "surface-tint": "#006f1d",
                    "outline-variant": "#acb4af",
                    "on-secondary-fixed-variant": "#755700",
                    "outline": "#757c79",
                    "secondary-container": "#ffdf9e",
                    "on-background": "#2d3431",
                    "primary-dim": "#006118",
                    "inverse-surface": "#0c0f0e",
                    "surface": "#f8faf7",
                    "surface-container-low": "#f1f5f1",
                    "surface-variant": "#dde4e0",
                    "tertiary-container": "#fd493b",
                    "surface-container": "#eaefeb",
                    "tertiary-dim": "#aa0208",
                    "on-primary": "#eaffe2",
                    "surface-container-lowest": "#ffffff",
                    "primary-fixed-dim": "#83e881",
                    "inverse-on-surface": "#9b9e9b",
                    "on-primary-fixed-variant": "#00691a",
                    "error-dim": "#791903",
                    "tertiary-fixed": "#fd493b"
            },
            "borderRadius": {
                    "DEFAULT": "1rem",
                    "lg": "2rem",
                    "xl": "3rem",
                    "full": "9999px"
            },
            "fontFamily": {
                    "headline": ["Inter"],
                    "body": ["Inter"],
                    "label": ["Inter"]
            }
          }
        }
      }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        body { font-family: 'Inter', sans-serif; }
        .breathing-bg {
            background: radial-gradient(circle at 50% 50%, rgba(145, 247, 142, 0.08) 0%, rgba(248, 250, 247, 0) 70%);
        }
        .bottom-sheet-shadow {
            box-shadow: 0 -10px 40px rgba(0, 0, 0, 0.08);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-surface text-on-surface min-h-screen flex flex-col items-center justify-end breathing-bg">
<!-- Content Background (Mocking the main screen behind the bottom sheet) -->
<div class="fixed inset-0 p-6 flex flex-col gap-6 opacity-40 pointer-events-none">
<header class="flex justify-between items-center">
<h1 class="text-display-lg font-bold tracking-tight text-on-surface-variant">Мой день</h1>
<div class="w-12 h-12 rounded-full bg-surface-container-highest"></div>
</header>
<div class="grid grid-cols-2 gap-4">
<div class="aspect-square bg-primary-container rounded-lg p-4 flex flex-col justify-between">
<span class="material-symbols-outlined text-on-primary-container">energy_savings_leaf</span>
<span class="text-headline-md font-semibold text-on-primary-container">80%</span>
</div>
<div class="aspect-square bg-secondary-container rounded-lg p-4 flex flex-col justify-between">
<span class="material-symbols-outlined text-on-secondary-container">schedule</span>
<span class="text-headline-md font-semibold text-on-secondary-container">14:00</span>
</div>
</div>
<div class="h-32 bg-surface-container-low rounded-lg w-full"></div>
</div>
<!-- Bottom Sheet Container -->
<div class="relative w-full max-w-2xl bg-surface-container-lowest rounded-t-xl bottom-sheet-shadow overflow-hidden flex flex-col">
<!-- Handle -->
<div class="flex justify-center py-3">
<div class="w-12 h-1.5 bg-surface-container-highest rounded-full"></div>
</div>
<!-- Form Content -->
<div class="px-8 pb-10 pt-4 flex flex-col gap-8">
<!-- Headline -->
<header class="flex flex-col gap-1">
<h2 class="text-headline-md font-semibold text-on-surface">Новая задача</h2>
<p class="text-label-md text-on-surface-variant uppercase tracking-widest">Проектирование дня</p>
</header>
<!-- Text Field Section -->
<section class="flex flex-col gap-3">
<label class="text-label-md font-medium text-on-surface-variant ml-1" for="task-input">Что нужно сделать?</label>
<div class="relative group">
<input class="w-full bg-surface-container-high border-none rounded-md px-5 py-4 text-body-lg focus:ring-2 focus:ring-primary focus:bg-surface-container-lowest transition-all placeholder:text-outline-variant outline-none" id="task-input" placeholder="Например: Завершить дизайн-систему" type="text"/>
</div>
</section>
<!-- Priority Selector (Asymmetric Layout) -->
<section class="flex flex-col gap-4">
<label class="text-label-md font-medium text-on-surface-variant ml-1">Приоритет</label>
<div class="grid grid-cols-3 gap-3">
<button class="flex flex-col items-center justify-center gap-2 p-4 rounded-md bg-tertiary-container/10 border-2 border-tertiary-container/30 text-tertiary-dim hover:bg-tertiary-container/20 transition-all active:scale-95">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">anchor</span>
<span class="text-label-md font-bold uppercase">P0 Якорь</span>
</button>
<button class="flex flex-col items-center justify-center gap-2 p-4 rounded-md bg-secondary-container text-on-secondary-container border-2 border-secondary-container hover:bg-secondary-fixed-dim transition-all active:scale-95 shadow-sm">
<span class="material-symbols-outlined">track_changes</span>
<span class="text-label-md font-bold uppercase">P1 Цель</span>
</button>
<button class="flex flex-col items-center justify-center gap-2 p-4 rounded-md bg-surface-container-high text-on-surface-variant border-2 border-transparent hover:bg-surface-container-highest transition-all active:scale-95">
<span class="material-symbols-outlined">redeem</span>
<span class="text-label-md font-bold uppercase">P2 Бонус</span>
</button>
</div>
</section>
<!-- Energy Cost Slider -->
<section class="flex flex-col gap-6 bg-surface-container-low p-6 rounded-lg">
<div class="flex justify-between items-end">
<div class="flex flex-col gap-1">
<label class="text-label-md font-medium text-on-surface-variant">Затраты энергии</label>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary">bolt</span>
<span class="text-title-lg font-semibold text-primary">Средне</span>
</div>
</div>
<span class="text-display-lg leading-none font-bold text-primary/20">03</span>
</div>
<!-- Custom Slider -->
<div class="relative h-12 flex items-center">
<div class="absolute w-full h-2 bg-surface-container-highest rounded-full"></div>
<div class="absolute w-3/5 h-2 bg-primary rounded-full"></div>
<div class="absolute left-3/5 -ml-4 w-8 h-8 bg-surface-container-lowest border-4 border-primary rounded-full shadow-lg cursor-pointer"></div>
<div class="absolute w-full flex justify-between top-10">
<span class="text-[10px] uppercase font-bold text-outline">Отдых</span>
<span class="text-[10px] uppercase font-bold text-outline">Фокус</span>
<span class="text-[10px] uppercase font-bold text-outline">Марафон</span>
</div>
</div>
</section>
<!-- Action Button -->
<button class="w-full py-5 rounded-full bg-gradient-to-r from-primary to-primary-dim text-on-primary font-bold text-title-lg shadow-xl shadow-primary/20 flex items-center justify-center gap-3 hover:opacity-90 active:scale-[0.98] transition-all">
<span class="material-symbols-outlined">add_task</span>
                Добавить в мой день
            </button>
</div>
<!-- Decorative Illustration Element -->
<div class="absolute -bottom-10 -right-10 w-40 h-40 bg-primary/5 rounded-full blur-3xl"></div>
</div>
<!-- Navigation Mockup (Using Shared Component Logic) -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 backdrop-blur-2xl rounded-t-[32px] shadow-2xl pointer-events-none opacity-20">
<div class="flex flex-col items-center justify-center text-stone-500 px-6 py-2">
<span class="material-symbols-outlined" data-icon="wb_sunny">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase">Сегодня</span>
</div>
<div class="flex flex-col items-center justify-center text-stone-500 px-6 py-2">
<span class="material-symbols-outlined" data-icon="event_note">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase">Планы</span>
</div>
<div class="flex flex-col items-center justify-center text-stone-500 px-6 py-2">
<span class="material-symbols-outlined" data-icon="Favorite">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase">Пульс</span>
</div>
<div class="flex flex-col items-center justify-center text-stone-500 px-6 py-2">
<span class="material-symbols-outlined" data-icon="history">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase">Архив</span>
</div>
</nav>
</body></html>

<!-- Конструктор задач (Bottom Sheet) -->
<!DOCTYPE html>

<html class="light" lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
      tailwind.config = {
        darkMode: "class",
        theme: {
          extend: {
            "colors": {
                    "surface-container-highest": "#dde4e0",
                    "on-secondary": "#fff8f0",
                    "primary-fixed": "#91f78e",
                    "on-secondary-fixed": "#523c00",
                    "secondary-fixed-dim": "#ffce5d",
                    "secondary": "#795a00",
                    "secondary-dim": "#6a4f00",
                    "on-surface-variant": "#59615d",
                    "on-tertiary-fixed": "#000000",
                    "on-tertiary-container": "#110000",
                    "surface-dim": "#d5dcd7",
                    "tertiary-fixed-dim": "#eb3c30",
                    "on-primary-container": "#005e17",
                    "primary": "#006f1d",
                    "error-container": "#fd795a",
                    "primary-container": "#91f78e",
                    "secondary-fixed": "#ffdf9e",
                    "on-error": "#fff7f6",
                    "on-primary-fixed": "#00480f",
                    "on-error-container": "#6e1400",
                    "background": "#f8faf7",
                    "on-tertiary": "#fff7f6",
                    "on-secondary-container": "#694d00",
                    "inverse-primary": "#91f78e",
                    "surface-bright": "#f8faf7",
                    "surface-container-high": "#e4e9e5",
                    "tertiary": "#bc1714",
                    "error": "#a73b21",
                    "on-tertiary-fixed-variant": "#340001",
                    "on-surface": "#2d3431",
                    "surface-tint": "#006f1d",
                    "outline-variant": "#acb4af",
                    "on-secondary-fixed-variant": "#755700",
                    "outline": "#757c79",
                    "secondary-container": "#ffdf9e",
                    "on-background": "#2d3431",
                    "primary-dim": "#006118",
                    "inverse-surface": "#0c0f0e",
                    "surface": "#f8faf7",
                    "surface-container-low": "#f1f5f1",
                    "surface-variant": "#dde4e0",
                    "tertiary-container": "#fd493b",
                    "surface-container": "#eaefeb",
                    "tertiary-dim": "#aa0208",
                    "on-primary": "#eaffe2",
                    "surface-container-lowest": "#ffffff",
                    "primary-fixed-dim": "#83e881",
                    "inverse-on-surface": "#9b9e9b",
                    "on-primary-fixed-variant": "#00691a",
                    "error-dim": "#791903",
                    "tertiary-fixed": "#fd493b"
            },
            "borderRadius": {
                    "DEFAULT": "1rem",
                    "lg": "2rem",
                    "xl": "3rem",
                    "full": "9999px"
            },
            "fontFamily": {
                    "headline": ["Inter"],
                    "body": ["Inter"],
                    "label": ["Inter"]
            }
          },
        },
      }
    </script>
<style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .breathing-bg {
            background: radial-gradient(circle at 50% 50%, rgba(188, 23, 20, 0.05) 0%, rgba(248, 250, 247, 1) 100%);
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-surface min-h-screen pb-32 breathing-bg">
<!-- TopAppBar -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 backdrop-blur-xl no-border bg-stone-100/50">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-highest">
<img alt="Profile photo" data-alt="Close-up portrait of a woman with soft lighting and natural skin texture, calm expression, cinematic lighting background" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBS7KfTK8IOdWN_gj0wtPkki0JhcV96yP32LA6aM2eMHJS8349_K8GSvIQ2JBJmnofcgIzYCoG4_VyyWBOJJsfZTqx56Fvic11Z5TVD7FOs1H1IiQC-0Nsrsb1vToRdOGf35y1lS4kNWHNS8twli7S_AK1ln7a5UEsYWcuFdpzqXe6udsD8Wp2781ADwhHaZ9pOjoTRZiW7iOs0ocJ4P8Bry2NM1d9Cz3vZB19gXCXfwHWg_fIbN-s7OX2PTLNYuGTLpi_KQw5mlw"/>
</div>
<h1 class="font-inter text-2xl font-semibold tracking-tight text-green-700">Мой день</h1>
</div>
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-green-700">energy_savings_leaf</span>
</div>
</header>
<main class="pt-24 px-6 max-w-2xl mx-auto">
<!-- Evening Greeting & Summary Hero -->
<section class="mb-12">
<p class="text-secondary font-medium label-md mb-2 opacity-80">Вечерний отчёт • 20:45</p>
<h2 class="text-[3.5rem] font-bold leading-tight tracking-tighter text-on-surface mb-6">
                Итоги твоего дня
            </h2>
<div class="bg-surface-container-low rounded-lg p-6 flex items-center justify-between">
<div>
<p class="text-on-surface-variant body-lg mb-1">Выполнено задач</p>
<p class="text-4xl font-bold text-primary">8 из 10</p>
</div>
<div class="w-16 h-16 rounded-full border-4 border-primary/20 flex items-center justify-center relative">
<svg class="absolute inset-0 transform -rotate-90">
<circle class="text-primary" cx="32" cy="32" fill="transparent" r="28" stroke="currentColor" stroke-dasharray="175" stroke-dashoffset="35" stroke-width="4"></circle>
</svg>
<span class="text-sm font-bold">80%</span>
</div>
</div>
</section>
<!-- Energy Graph Section -->
<section class="mb-12">
<div class="flex justify-between items-end mb-6">
<h3 class="text-1.75rem font-semibold headline-md text-on-surface">Пульс энергии</h3>
<span class="bg-tertiary-container/10 text-tertiary px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Фаза покоя</span>
</div>
<div class="h-48 flex items-end justify-between gap-2 px-2 bg-surface-container-lowest rounded-lg p-6 shadow-sm">
<!-- Simple Asymmetric Bar Chart Visualization -->
<div class="flex-1 bg-primary-container/40 rounded-t-full h-[60%] relative group">
<div class="absolute -top-8 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity text-[10px] font-bold">08:00</div>
</div>
<div class="flex-1 bg-primary-container rounded-t-full h-[85%]"></div>
<div class="flex-1 bg-primary-container h-[95%] rounded-t-full"></div>
<div class="flex-1 bg-secondary-container h-[70%] rounded-t-full"></div>
<div class="flex-1 bg-secondary-container h-[55%] rounded-t-full"></div>
<div class="flex-1 bg-tertiary-container/60 h-[40%] rounded-t-full"></div>
<div class="flex-1 bg-tertiary-container h-[25%] rounded-t-full"></div>
</div>
<div class="flex justify-between mt-4 px-2 text-on-surface-variant text-xs font-medium">
<span>Утро</span>
<span>День</span>
<span>Вечер</span>
</div>
</section>
<!-- Completed Tasks Bento Section -->
<section class="mb-12">
<h3 class="text-1.75rem font-semibold headline-md text-on-surface mb-6">Завершенные дела</h3>
<div class="grid grid-cols-2 gap-4">
<div class="col-span-2 bg-surface-container-low rounded-lg p-5 flex items-start gap-4">
<div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
<div>
<h4 class="font-medium text-on-surface">Утренняя йога</h4>
<p class="text-sm text-on-surface-variant">20 минут растяжки и дыхания</p>
</div>
</div>
<div class="bg-surface-container-low rounded-lg p-5">
<span class="material-symbols-outlined text-secondary mb-2">work</span>
<h4 class="font-medium text-on-surface">Проект X</h4>
<p class="text-xs text-on-surface-variant mt-1">Финальные правки</p>
</div>
<div class="bg-surface-container-low rounded-lg p-5">
<span class="material-symbols-outlined text-primary mb-2">menu_book</span>
<h4 class="font-medium text-on-surface">Чтение</h4>
<p class="text-xs text-on-surface-variant mt-1">15 страниц книги</p>
</div>
</div>
</section>
<!-- Reflection Input -->
<section class="mb-12">
<h3 class="text-1.75rem font-semibold headline-md text-on-surface mb-6">Как прошёл день?</h3>
<div class="relative">
<input class="w-full bg-surface-container-high border-none rounded-lg p-6 text-xl font-medium focus:ring-2 focus:ring-tertiary-container focus:bg-surface-container-lowest transition-all duration-300 placeholder:text-on-surface-variant/40" placeholder="Опиши одним словом..." type="text"/>
<button class="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 rounded-full bg-tertiary text-on-tertiary flex items-center justify-center shadow-lg active:scale-90 transition-transform">
<span class="material-symbols-outlined">arrow_forward</span>
</button>
</div>
<div class="flex flex-wrap gap-2 mt-4">
<button class="px-4 py-2 rounded-full bg-surface-container-highest text-on-surface-variant text-sm hover:bg-tertiary-container hover:text-on-tertiary transition-colors">Продуктивно</button>
<button class="px-4 py-2 rounded-full bg-surface-container-highest text-on-surface-variant text-sm hover:bg-tertiary-container hover:text-on-tertiary transition-colors">Спокойно</button>
<button class="px-4 py-2 rounded-full bg-surface-container-highest text-on-surface-variant text-sm hover:bg-tertiary-container hover:text-on-tertiary transition-colors">Утомительно</button>
</div>
</section>
<!-- Final Quote / Insight -->
<section class="mt-16 text-center italic text-on-surface-variant/70 body-lg">
            "Завтра — это новый холст. Время дать краскам высохнуть."
        </section>
</main>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 backdrop-blur-2xl rounded-t-[32px] shadow-2xl dark:shadow-none no-border">
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Сегодня</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Планы</span>
</a>
<a class="flex flex-col items-center justify-center text-stone-500 px-6 py-2 hover:text-green-600 transition-colors" href="#">
<span class="material-symbols-outlined">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Пульс</span>
</a>
<a class="flex flex-col items-center justify-center bg-green-100 text-green-800 rounded-full px-6 py-2 scale-95 transition-all duration-200" href="#">
<span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1;">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Архив</span>
</a>
</nav>
</body></html>

<!-- Вечерний отчёт -->
<!DOCTYPE html>

<html lang="ru"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Мой день - Сделай паузу</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    "colors": {
                        "surface-container-highest": "#dde4e0",
                        "on-secondary": "#fff8f0",
                        "primary-fixed": "#91f78e",
                        "on-secondary-fixed": "#523c00",
                        "secondary-fixed-dim": "#ffce5d",
                        "secondary": "#795a00",
                        "secondary-dim": "#6a4f00",
                        "on-surface-variant": "#59615d",
                        "on-tertiary-fixed": "#000000",
                        "on-tertiary-container": "#110000",
                        "surface-dim": "#d5dcd7",
                        "tertiary-fixed-dim": "#eb3c30",
                        "on-primary-container": "#005e17",
                        "primary": "#006f1d",
                        "error-container": "#fd795a",
                        "primary-container": "#91f78e",
                        "secondary-fixed": "#ffdf9e",
                        "on-error": "#fff7f6",
                        "on-primary-fixed": "#00480f",
                        "on-error-container": "#6e1400",
                        "background": "#f8faf7",
                        "on-tertiary": "#fff7f6",
                        "on-secondary-container": "#694d00",
                        "inverse-primary": "#91f78e",
                        "surface-bright": "#f8faf7",
                        "surface-container-high": "#e4e9e5",
                        "tertiary": "#bc1714",
                        "error": "#a73b21",
                        "on-tertiary-fixed-variant": "#340001",
                        "on-surface": "#2d3431",
                        "surface-tint": "#006f1d",
                        "outline-variant": "#acb4af",
                        "on-secondary-fixed-variant": "#755700",
                        "outline": "#757c79",
                        "secondary-container": "#ffdf9e",
                        "on-background": "#2d3431",
                        "primary-dim": "#006118",
                        "inverse-surface": "#0c0f0e",
                        "surface": "#f8faf7",
                        "surface-container-low": "#f1f5f1",
                        "surface-variant": "#dde4e0",
                        "tertiary-container": "#fd493b",
                        "surface-container": "#eaefeb",
                        "tertiary-dim": "#aa0208",
                        "on-primary": "#eaffe2",
                        "surface-container-lowest": "#ffffff",
                        "primary-fixed-dim": "#83e881",
                        "inverse-on-surface": "#9b9e9b",
                        "on-primary-fixed-variant": "#00691a",
                        "error-dim": "#791903",
                        "tertiary-fixed": "#fd493b"
                    },
                    "borderRadius": {
                        "DEFAULT": "1rem",
                        "lg": "2rem",
                        "xl": "3rem",
                        "full": "9999px"
                    },
                    "fontFamily": {
                        "headline": ["Inter"],
                        "body": ["Inter"],
                        "label": ["Inter"]
                    }
                },
            },
        }
    </script>
<style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .bg-breathing-gradient {
            background: radial-gradient(circle at center, #fd493b 0%, #f8faf7 70%);
            opacity: 0.08;
        }
    </style>
<style>
    body {
      min-height: max(884px, 100dvh);
    }
  </style>
  </head>
<body class="bg-background text-on-background font-body min-h-screen relative overflow-hidden">
<!-- Background Atmospheric Layer -->
<div class="fixed inset-0 bg-breathing-gradient pointer-events-none"></div>
<!-- Main Content Canvas (Background View) -->
<main class="px-6 pt-24 pb-32">
<header class="mb-12">
<h1 class="text-[3.5rem] font-bold tracking-tight text-on-surface leading-tight mb-2">Мой день</h1>
<p class="text-on-surface-variant text-lg">Сегодня — время для заботы о себе.</p>
</header>
<div class="space-y-6">
<div class="bg-surface-container-low p-6 rounded-lg">
<div class="flex justify-between items-center mb-4">
<span class="text-tertiary font-medium">Текущая задача</span>
<span class="text-xs bg-tertiary-container/20 text-tertiary px-3 py-1 rounded-full">P1 • Срочно</span>
</div>
<h3 class="text-xl font-semibold mb-2">Завершить квартальный отчет</h3>
<p class="text-on-surface-variant leading-relaxed">Осталось 4 часа до дедлайна. Сложность: Высокая.</p>
</div>
<div class="grid grid-cols-2 gap-4">
<div class="bg-surface-container-lowest p-6 rounded-lg">
<span class="material-symbols-outlined text-secondary mb-2" data-icon="energy_savings_leaf">energy_savings_leaf</span>
<div class="text-2xl font-bold">42%</div>
<div class="text-xs uppercase tracking-wider text-on-surface-variant">Энергия</div>
</div>
<div class="bg-surface-container-lowest p-6 rounded-lg">
<span class="material-symbols-outlined text-primary mb-2" data-icon="nest_clock_farsight_analog">nest_clock_farsight_analog</span>
<div class="text-2xl font-bold">3/8</div>
<div class="text-xs uppercase tracking-wider text-on-surface-variant">Задачи</div>
</div>
</div>
</div>
</main>
<!-- Bottom Sheet Overlay (Dimmer) -->
<div class="fixed inset-0 bg-on-surface/40 backdrop-blur-sm z-[60]"></div>
<!-- Bottom Sheet Component: Сделай паузу -->
<div class="fixed bottom-0 left-0 w-full z-[70] transition-transform duration-500 ease-out translate-y-0">
<div class="bg-surface-container-lowest rounded-t-[3rem] shadow-2xl px-6 pt-4 pb-12 max-w-2xl mx-auto border-t border-white/20">
<!-- Handle -->
<div class="w-12 h-1.5 bg-outline-variant/30 rounded-full mx-auto mb-8"></div>
<!-- Header Section -->
<div class="mb-8 text-center">
<div class="inline-flex items-center justify-center w-16 h-16 bg-tertiary-container/10 rounded-full mb-4">
<span class="material-symbols-outlined text-tertiary text-4xl" data-icon="favorite" style="font-variation-settings: 'FILL' 1;">favorite</span>
</div>
<h2 class="text-[2rem] font-bold text-on-surface tracking-tight mb-2">Сделай паузу</h2>
<p class="text-on-surface-variant max-w-xs mx-auto">Мы видим, что сейчас непросто. Выбери то, что поможет тебе восстановиться.</p>
</div>
<!-- Options Grid / Bento Style -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
<!-- Option 1: Breathing Exercise (Large Feature) -->
<button class="md:col-span-2 group relative overflow-hidden bg-tertiary-container/5 hover:bg-tertiary-container/10 transition-all duration-300 p-8 rounded-lg text-left flex flex-col items-center text-center">
<div class="absolute inset-0 bg-gradient-to-b from-tertiary-container/5 to-transparent pointer-events-none"></div>
<div class="relative w-32 h-32 mb-6 flex items-center justify-center">
<div class="absolute inset-0 bg-tertiary-container/20 rounded-full scale-100 opacity-60"></div>
<div class="absolute inset-4 bg-tertiary-container/30 rounded-full scale-90 opacity-40"></div>
<span class="material-symbols-outlined text-tertiary text-5xl relative z-10" data-icon="air">air</span>
</div>
<h3 class="text-xl font-bold text-tertiary mb-2">Дыхание 4-7-8</h3>
<p class="text-on-surface-variant text-sm leading-relaxed max-w-[240px]">Успокой нервную систему за 2 минуты</p>
</button>
<!-- Option 2: Cancel P1/P2 Tasks -->
<button class="group bg-surface-container-high hover:bg-tertiary-container/10 transition-all duration-300 p-6 rounded-lg text-left">
<div class="w-10 h-10 rounded-full bg-tertiary/10 flex items-center justify-center mb-4 group-hover:bg-tertiary/20">
<span class="material-symbols-outlined text-tertiary" data-icon="event_busy">event_busy</span>
</div>
<h3 class="text-lg font-bold text-on-surface mb-1">Отложить всё</h3>
<p class="text-on-surface-variant text-sm">Перенести важные задачи P1/P2 на завтра</p>
</button>
<!-- Option 3: Micro-step -->
<button class="group bg-surface-container-high hover:bg-primary-container/20 transition-all duration-300 p-6 rounded-lg text-left">
<div class="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center mb-4 group-hover:bg-primary/20">
<span class="material-symbols-outlined text-primary" data-icon="splitscreen">splitscreen</span>
</div>
<h3 class="text-lg font-bold text-on-surface mb-1">Микро-шаг</h3>
<p class="text-on-surface-variant text-sm">Разбить текущую задачу на 3 крошечных действия</p>
</button>
</div>
<!-- Close/Cancel Action -->
<div class="mt-8">
<button class="w-full py-4 text-on-surface-variant font-medium hover:text-on-surface transition-colors">
                    Я справлюсь, вернуться к делам
                </button>
</div>
</div>
</div>
<!-- Navigation Components (JSON Based Shells) -->
<!-- TopAppBar -->
<header class="fixed top-0 left-0 w-full z-50 flex justify-between items-center px-6 py-4 bg-stone-50/60 dark:bg-stone-900/60 backdrop-blur-xl">
<div class="flex items-center gap-3">
<div class="w-10 h-10 rounded-full overflow-hidden bg-surface-container-highest">
<img alt="User profile photo" class="w-full h-full object-cover" data-alt="Close-up portrait of a serene young woman with soft natural lighting and neutral background" src="https://lh3.googleusercontent.com/aida-public/AB6AXuC9r9T8xeMPZK0WZ5ES5CtiDa3r0CG7CrtPYLShsc72tdOWyDZ100lH2Az28X35nDpsVSZr_kqMAhV2d0N-mgLigza54Vlk6NaP8HroTLudI1UwSkD-zkS971MBhJnxBO-MqFfvbPhM_2sfRonvfsXkYuw9LcII377fyUBr697EbzjGJNGmngVy2mBybSpVRJlE_ts2OLkKFzNr2cr7tV6cnZI0ncmX14AyJZXMQgPBe-JC-2nCCnOTAblqq4VIz_8I9slSMD5Omw"/>
</div>
<span class="font-inter text-2xl font-semibold tracking-tight text-green-700 dark:text-green-400">Мой день</span>
</div>
<button class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-stone-200/50 dark:hover:bg-stone-800/50 transition-colors Active: scale-95 transition-transform duration-300">
<span class="material-symbols-outlined text-green-700 dark:text-green-400" data-icon="energy_savings_leaf">energy_savings_leaf</span>
</button>
</header>
<!-- BottomNavBar -->
<nav class="fixed bottom-0 left-0 w-full z-50 flex justify-around items-center px-4 pb-6 pt-3 bg-stone-50/80 dark:bg-stone-900/80 backdrop-blur-2xl rounded-t-[32px] shadow-2xl dark:shadow-none">
<button class="flex flex-col items-center justify-center bg-green-100 dark:bg-green-900/40 text-green-800 dark:text-green-100 rounded-full px-6 py-2 transition-all duration-200 scale-90">
<span class="material-symbols-outlined" data-icon="wb_sunny">wb_sunny</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Сегодня</span>
</button>
<button class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300">
<span class="material-symbols-outlined" data-icon="event_note">event_note</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Планы</span>
</button>
<button class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300">
<span class="material-symbols-outlined" data-icon="Favorite">favorite</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Пульс</span>
</button>
<button class="flex flex-col items-center justify-center text-stone-500 dark:text-stone-400 px-6 py-2 hover:text-green-600 dark:hover:text-green-300">
<span class="material-symbols-outlined" data-icon="history">history</span>
<span class="font-inter text-[11px] font-medium tracking-wide uppercase mt-1">Архив</span>
</button>
</nav>
</body></html>