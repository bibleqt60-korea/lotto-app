import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin
    _notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ),
    iOS: DarwinInitializationSettings(),
  );

  await _notifications.initialize(
    settings,
  );
}