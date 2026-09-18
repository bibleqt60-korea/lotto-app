import '../models/lotto_result.dart';
import '../models/my_lotto_number.dart';
import '../utils/lotto_calculator.dart';
import 'my_number_storage_service.dart';

class MyNumberService {
  MyNumberService();

  final MyNumberStorageService _storage =
      MyNumberStorageService();

  Future<List<MyLottoNumber>> getAll() {
    return _storage.loadAll();
  }

  Future<void> save(
    List<int> numbers, {
    String memo = '',
  }) async {
    final sorted = [...numbers]..sort();

    final item = MyLottoNumber(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      numbers: sorted,
      createdAt: DateTime.now(),
      memo: memo,
    );

    await _storage.save(item);
  }

  Future<void> update(
    MyLottoNumber item,
  ) {
    return _storage.save(item);
  }

  Future<void> delete(String id) {
    return _storage.delete(id);
  }

  Future<void> clear() {
    return _storage.clear();
  }

  int getRank(
    List<int> myNumbers,
    LottoResult result,
  ) {
    return LottoCalculator.getRank(
      myNumbers,
      result.numbers,
      result.bonusNumber,
    );
  }

  int getMatchCount(
    List<int> myNumbers,
    LottoResult result,
  ) {
    return LottoCalculator.countMatches(
      myNumbers,
      result.numbers,
    );
  }

  bool hasBonus(
    List<int> myNumbers,
    LottoResult result,
  ) {
    return myNumbers.contains(
      result.bonusNumber,
    );
  }

  Map<String, dynamic> checkWinning(
    List<int> myNumbers,
    LottoResult result,
  ) {
    final matches = getMatchCount(
      myNumbers,
      result,
    );

    final bonus = hasBonus(
      myNumbers,
      result,
    );

    final rank = getRank(
      myNumbers,
      result,
    );

    return {
      'round': result.round,
      'numbers': [...myNumbers]..sort(),
      'matchCount': matches,
      'bonus': bonus,
      'rank': rank,
      'isWinner': rank > 0,
      'prize': _getPrize(result, rank),
    };
  }

  int _getPrize(
    LottoResult result,
    int rank,
  ) {
    switch (rank) {
      case 1:
        return result.firstPrize;
      case 2:
        return result.secondPrize;
      case 3:
        return result.thirdPrize;
      case 4:
        return result.fourthPrize;
      case 5:
        return result.fifthPrize;
      default:
        return 0;
    }
  }
}