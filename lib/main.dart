import 'package:flutter/material.dart';
import 'services/data_service.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/smart_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.instance.init();
  await ProfileService.instance.init();
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
        colorSchemeSeed: const Color(0xFF006F1D),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006F1D),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool get _showEntry => DataService.instance.shouldShowEntry;

  void _onEntryDone() {
    DataService.instance.markEntryShown();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_showEntry) {
      return SmartEntryScreen(onDone: _onEntryDone);
    }
    return const DashboardScreen();
  }
}
