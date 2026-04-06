# Мой день — Flutter App

## Документация
Вся продуктовая документация в `reference/MoyDen_PDD.docx` — читай её первой.
Рабочая PWA версия в `reference/pwa_reference.html` — источник всех текстов, задач и логики.

## Текущее состояние
Flutter 3.27.4 / Dart 3.6.2 / Material 3 / Windows
Создан базовый Dashboard экран в `lib/main.dart`.

## Правила
- Тексты задач и подсказок — только из pwa_reference.html, не придумывай
- Тема — ThemeMode.system (авто по системе)
- Комментарии в коде — на русском
- Каждый экран — отдельный файл в lib/screens/
- Общие виджеты — lib/widgets/
- Логика данных — lib/services/
- Константы и тексты — lib/constants/

## Прогресс
Текущий статус задач — в `PROGRESS.md`.
Перед началом работы читай его, обновляй когда я попрошу тебя, сам не трогай.

## Деплой
- Android: flutter build apk
- Web: flutter build web → GitHub Pages
- Запуск на Windows: flutter run -d edge


Переменная для Яндекс Браузера (если нужен flutter run):
```powershell
$env:CHROME_EXECUTABLE = "C:\Users\Andrew\AppData\Local\Yandex\YandexBrowser\Application\browser.exe"
flutter run -d chrome
```