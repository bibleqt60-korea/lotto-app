import 'notification_service.dart';
import 'lotto_repository.dart';

class AppInitializer {
  AppInitializer._();

  static final AppInitializer instance =
      AppInitializer._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await NotificationService.initialize();

    try {
      await LottoRepository.instance
          .syncLatest();
    } catch (_) {
      // 인터넷 연결 실패 시에도
      // 앱은 정상적으로 실행되도록 한다.
    }

    _initialized = true;
  }
}