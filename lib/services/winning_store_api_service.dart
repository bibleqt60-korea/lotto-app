import '../models/winning_store.dart';
import 'winning_store_service.dart';

class WinningStoreApiService {
  final WinningStoreService _service =
      WinningStoreService();

  Future<List<WinningStore>> getStores(
    int round,
  ) {
    return _service.getStores(round);
  }

  Future<List<WinningStore>> getFirstStores(
    int round,
  ) {
    return _service.getFirstStores(round);
  }

  Future<List<WinningStore>> getSecondStores(
    int round,
  ) {
    return _service.getSecondStores(round);
  }
}