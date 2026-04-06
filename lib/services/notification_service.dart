import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Сервис уведомлений (базовая реализация)
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Android настройки
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS настройки (базовые)
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Инициализация плагина
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _initialized = true;
    } catch (e) {
      // Логирование ошибок при необходимости
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Обработка тапа по уведомлению
  }

  // Показать одиночное уведомление
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'moiden_general',
            'Мой день',
            channelDescription: 'Общие уведомления',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      // Логирование ошибок при необходимости
    }
  }
}
