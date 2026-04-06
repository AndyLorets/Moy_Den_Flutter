import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'services/notification_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/help_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/smart_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.instance.init();
  // Инициализируем уведомления (требует разрешений на Android)
  await NotificationService.instance.init();
  runApp(const MoyDenApp());
}

class MoyDenApp extends StatelessWidget {
  const MoyDenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой день',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFC8A96E), // золотой акцент из референса
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFC8A96E),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

// Главная оболочка с нижней навигацией
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  // Показываем Smart Entry если ещё не было сегодня
  bool get _showEntry => DataService.instance.shouldShowEntry;

  void _refresh() => setState(() {});

  void _onEntryDone() {
    DataService.instance.markEntryShown();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Smart Entry — поверх всего, без навигации
    if (_showEntry) {
      return SmartEntryScreen(onDone: _onEntryDone);
    }

    final screens = [
      const DashboardScreen(),
      OverviewScreen(onChanged: _refresh),
      const ScheduleScreen(),
      const HelpScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'День',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Задачи',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'График',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Справка',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
