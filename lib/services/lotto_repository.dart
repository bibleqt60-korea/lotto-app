import '../models/lotto_result.dart';
import 'lotto_api_service.dart';
import 'lotto_storage_service.dart';

class LottoSyncResult {
  final int previousRound;
  final int latestRound;
  final int addedCount;

  const LottoSyncResult({
    required this.previousRound,
    required this.latestRound,
    required this.addedCount,
  });

  bool get hasNewData => addedCount > 0;
}

class LottoRepository {
  LottoRepository._();

  static final LottoRepository instance =
      LottoRepository._();

  final LottoStorageService _storage =
      LottoStorageService.instance;

  final LottoApiService _api =
      LottoApiService();

  Future<List<LottoResult>> getAll() async {
    final local = await _storage.loadAll();

    if (local.isNotEmpty) {
      return local;
    }

    final remote = await _api.getAll();

    if (remote.isNotEmpty) {
      await _storage.saveAll(remote);
    }

    return remote;
  }

  Future<List<LottoResult>> getAllLocal() {
    return _storage.loadAll();
  }

  Future<LottoResult?> getLatest() async {
    final local = await _storage.getLatest();

    if (local != null) {
      return local;
    }

    final results = await getAll();

    if (results.isEmpty) {
      return null;
    }

    return results.last;
  }

  Future<LottoResult?> getLatestLocal() {
    return _storage.getLatest();
  }

  Future<LottoResult?> getRound(int round) async {
    final local =
        await _storage.getRound(round);

    if (local != null) {
      return local;
    }

    final results = await getAll();

    for (final result in results) {
      if (result.round == round) {
        await _storage.saveRound(result);
        return result;
      }
    }

    return null;
  }

  Future<LottoSyncResult> syncNewRounds() async {
    final local =
        await _storage.loadAll();

    final previousRound =
        local.isEmpty ? 0 : local.last.round;

    final latestRound =
        await _api.getLatestRound();

    if (latestRound <= previousRound) {
      return LottoSyncResult(
        previousRound: previousRound,
        latestRound: latestRound,
        addedCount: 0,
      );
    }

    final remote = await _api.getAll();

    if (remote.isEmpty) {
      return LottoSyncResult(
        previousRound: previousRound,
        latestRound: previousRound,
        addedCount: 0,
      );
    }

    final existingRounds =
        local.map((item) => item.round).toSet();

    var addedCount = 0;

    for (final result in remote) {
      if (!existingRounds.contains(result.round)) {
        local.add(result);
        addedCount++;
      }
    }

    local.sort(
      (a, b) => a.round.compareTo(b.round),
    );

    await _storage.saveAll(local);

    return LottoSyncResult(
      previousRound: previousRound,
      latestRound: remote.last.round,
      addedCount: addedCount,
    );
  }

  Future<LottoSyncResult> syncLatest() {
    return syncNewRounds();
  }

  Future<LottoSyncResult> syncAll() {
    return syncNewRounds();
  }
}