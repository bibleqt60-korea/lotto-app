import 'notification_service_io.dart'
    if (dart.library.html) 'notification_service_web.dart';

class NotificationService {
  NotificationService._();

  static Future<void> initialize() {
    return initializeNotifications();
  }
}