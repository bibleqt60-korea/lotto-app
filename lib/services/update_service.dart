import 'lotto_repository.dart';

class UpdateService {
  UpdateService();

  final LottoRepository _lottoRepository =
      LottoRepository.instance;

  Future<UpdateResult> update() async {
    final lottoResult =
        await _lottoRepository.syncNewRounds();

    return UpdateResult(
      previousRound:
          lottoResult.previousRound,
      latestRound:
          lottoResult.latestRound,
      addedCount:
          lottoResult.addedCount,
    );
  }

  Future<UpdateResult> sync() {
    return update();
  }

  Future<UpdateResult> refresh() {
    return update();
  }
}

class UpdateResult {
  final int previousRound;
  final int latestRound;
  final int addedCount;

  const UpdateResult({
    required this.previousRound,
    required this.latestRound,
    required this.addedCount,
  });

  bool get hasNewData =>
      addedCount > 0;
}