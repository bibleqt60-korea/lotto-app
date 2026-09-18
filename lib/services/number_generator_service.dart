import 'dart:math';

import '../models/lotto_result.dart';
import '../utils/lotto_calculator.dart';

class NumberGeneratorSettings {
  final bool useFrequency;
  final int frequencyMin;
  final int frequencyMax;

  final bool useRecent;
  final int recentGames;
  final int recentMin;
  final int recentMax;

  final bool useOverdue;
  final int overdueMin;
  final int overdueMax;

  final bool useOddEven;
  final int oddCount;

  final bool useLowHigh;
  final int lowCount;

  final bool useSum;
  final int minSum;
  final int maxSum;

  final bool useAc;
  final int minAc;
  final int maxAc;

  final bool useConsecutive;
  final int minConsecutive;
  final int maxConsecutive;

  final bool useEnding;
  final int maxSameEnding;

  final bool useRange;
  final List<int> rangePattern;

  final bool usePrime;
  final int minPrime;
  final int maxPrime;

  final bool usePreviousOverlap;
  final int maxPreviousOverlap;

  final List<int> fixedNumbers;
  final List<int> excludedNumbers;

  const NumberGeneratorSettings({
    this.useFrequency = false,
    this.frequencyMin = 0,
    this.frequencyMax = 999,
    this.useRecent = false,
    this.recentGames = 10,
    this.recentMin = 0,
    this.recentMax = 10,
    this.useOverdue = false,
    this.overdueMin = 0,
    this.overdueMax = 999,
    this.useOddEven = false,
    this.oddCount = 3,
    this.useLowHigh = false,
    this.lowCount = 3,
    this.useSum = false,
    this.minSum = 100,
    this.maxSum = 200,
    this.useAc = false,
    this.minAc = 7,
    this.maxAc = 20,
    this.useConsecutive = false,
    this.minConsecutive = 0,
    this.maxConsecutive = 2,
    this.useEnding = false,
    this.maxSameEnding = 2,
    this.useRange = false,
    this.rangePattern = const [
      -1,
      -1,
      -1,
      -1,
      -1,
    ],
    this.usePrime = false,
    this.minPrime = 0,
    this.maxPrime = 6,
    this.usePreviousOverlap = false,
    this.maxPreviousOverlap = 2,
    this.fixedNumbers = const [],
    this.excludedNumbers = const [],
  });
}

class NumberGeneratorService {
  final Random _random = Random();

  List<List<int>> generateMultiple({
    required int count,
    required List<LottoResult> history,
    NumberGeneratorSettings settings =
        const NumberGeneratorSettings(),
  }) {
    if (count <= 0 || history.isEmpty) {
      return [];
    }

    final previousNumbers =
        history.last.numbers;

    return generate(
      count: count,
      history: history,
      settings: settings,
      previousNumbers: previousNumbers,
    );
  }

  List<List<int>> generate({
    required int count,
    required List<LottoResult> history,
    NumberGeneratorSettings settings =
        const NumberGeneratorSettings(),
    List<int> previousNumbers = const [],
  }) {
    if (count <= 0) {
      return [];
    }

    final results = <List<int>>[];
    final used = <String>{};

    final frequency =
        _frequencyMap(history);

    final recent =
        _recentMap(
      history,
      settings.recentGames,
    );

    final overdue =
        _overdueMap(history);

    var attempts = 0;
    final maxAttempts =
        count * 10000;

    while (
        results.length < count &&
        attempts < maxAttempts) {
      attempts++;

      final numbers =
          _createCandidate(
        frequency: frequency,
        recent: recent,
        overdue: overdue,
        settings: settings,
      );

      if (numbers == null) {
        continue;
      }

      if (!_matchesAllConditions(
        numbers,
        history,
        settings,
        previousNumbers,
        frequency,
        recent,
        overdue,
      )) {
        continue;
      }

      final key =
          numbers.join(',');

      if (used.contains(key)) {
        continue;
      }

      used.add(key);
      results.add(numbers);
    }

    return results;
  }

  List<int>? _createCandidate({
    required Map<int, int> frequency,
    required Map<int, int> recent,
    required Map<int, int> overdue,
    required NumberGeneratorSettings settings,
  }) {
    final excluded =
        settings.excludedNumbers.toSet();

    final fixed = settings.fixedNumbers
        .where(
          (number) =>
              number >= 1 &&
              number <= 45,
        )
        .toSet();

    if (fixed.length > 6) {
      return null;
    }

    if (fixed.any(
      excluded.contains,
    )) {
      return null;
    }

    final numbers =
        <int>{...fixed};

    final available =
        List<int>.generate(
      45,
      (index) => index + 1,
    ).where(
      (number) =>
          !excluded.contains(number) &&
          !numbers.contains(number),
    ).toList();

    while (numbers.length < 6) {
      if (available.isEmpty) {
        return null;
      }

      final selected =
          _weightedPick(
        available,
        frequency,
        recent,
        overdue,
        settings,
      );

      numbers.add(selected);
      available.remove(selected);
    }

    return numbers.toList()..sort();
  }

  int _weightedPick(
    List<int> available,
    Map<int, int> frequency,
    Map<int, int> recent,
    Map<int, int> overdue,
    NumberGeneratorSettings settings,
  ) {
    if (!settings.useFrequency &&
        !settings.useRecent &&
        !settings.useOverdue) {
      return available[
          _random.nextInt(
        available.length,
      )];
    }

    final weights = <double>[];
    var total = 0.0;

    for (final number in available) {
      var weight = 1.0;

      if (settings.useFrequency) {
        weight +=
            (frequency[number] ?? 0) *
                0.05;
      }

      if (settings.useRecent) {
        weight +=
            (recent[number] ?? 0) *
                0.20;
      }

      if (settings.useOverdue) {
        weight +=
            (overdue[number] ?? 0) *
                0.05;
      }

      weights.add(weight);
      total += weight;
    }

    var target =
        _random.nextDouble() *
            total;

    for (var i = 0;
        i < available.length;
        i++) {
      target -= weights[i];

      if (target <= 0) {
        return available[i];
      }
    }

    return available.last;
  }

  bool _matchesAllConditions(
    List<int> numbers,
    List<LottoResult> history,
    NumberGeneratorSettings settings,
    List<int> previousNumbers,
    Map<int, int> frequency,
    Map<int, int> recent,
    Map<int, int> overdue,
  ) {
    if (numbers.length != 6) {
      return false;
    }

    if (settings.useFrequency) {
      for (final number in numbers) {
        final value =
            frequency[number] ?? 0;

        if (value <
                settings.frequencyMin ||
            value >
                settings.frequencyMax) {
          return false;
        }
      }
    }

    if (settings.useRecent) {
      for (final number in numbers) {
        final value =
            recent[number] ?? 0;

        if (value <
                settings.recentMin ||
            value >
                settings.recentMax) {
          return false;
        }
      }
    }

    if (settings.useOverdue) {
      for (final number in numbers) {
        final value =
            overdue[number] ?? 0;

        if (value <
                settings.overdueMin ||
            value >
                settings.overdueMax) {
          return false;
        }
      }
    }

    if (settings.useOddEven) {
      final odd =
          LottoCalculator.oddCount(
        numbers,
      );

      if (odd != settings.oddCount) {
        return false;
      }
    }

    if (settings.useLowHigh) {
      final low =
          LottoCalculator.lowHighCount(
        numbers,
      )['low']!;

      if (low != settings.lowCount) {
        return false;
      }
    }

    if (settings.useSum) {
      final total =
          LottoCalculator.sum(
        numbers,
      );

      if (total < settings.minSum ||
          total > settings.maxSum) {
        return false;
      }
    }

    if (settings.useAc) {
      final ac =
          LottoCalculator.acValue(
        numbers,
      );

      if (ac < settings.minAc ||
          ac > settings.maxAc) {
        return false;
      }
    }

    if (settings.useConsecutive) {
      final consecutive =
          LottoCalculator
              .consecutivePairs(
        numbers,
      );

      if (consecutive <
              settings.minConsecutive ||
          consecutive >
              settings.maxConsecutive) {
        return false;
      }
    }

    if (settings.useEnding) {
      final maxEnding =
          LottoCalculator
              .maxEndingDigitCount(
        numbers,
      );

      if (maxEnding >
          settings.maxSameEnding) {
        return false;
      }
    }

    if (settings.useRange) {
      if (!_matchesRange(
        numbers,
        settings.rangePattern,
      )) {
        return false;
      }
    }

    if (settings.usePrime) {
      final prime =
          LottoCalculator.primeCount(
        numbers,
      );

      if (prime < settings.minPrime ||
          prime > settings.maxPrime) {
        return false;
      }
    }

    if (settings.usePreviousOverlap) {
      final target =
          previousNumbers.isNotEmpty
              ? previousNumbers
              : history.isEmpty
                  ? const <int>[]
                  : history.last.numbers;

      if (target.isNotEmpty) {
        final overlap = numbers
            .where(target.contains)
            .length;

        if (overlap >
            settings.maxPreviousOverlap) {
          return false;
        }
      }
    }

    return true;
  }

  bool _matchesRange(
    List<int> numbers,
    List<int> pattern,
  ) {
    if (pattern.length != 5) {
      return true;
    }

    return LottoCalculator
        .matchesRangePattern(
      numbers,
      pattern,
    );
  }

  Map<int, int> _frequencyMap(
    List<LottoResult> history,
  ) {
    final result =
        <int, int>{
      for (var number = 1;
          number <= 45;
          number++)
        number: 0,
    };

    for (final lotto in history) {
      for (final number in lotto.numbers) {
        result[number] =
            (result[number] ?? 0) + 1;
      }
    }

    return result;
  }

  Map<int, int> _recentMap(
    List<LottoResult> history,
    int count,
  ) {
    final result =
        <int, int>{
      for (var number = 1;
          number <= 45;
          number++)
        number: 0,
    };

    final sorted = [...history]
      ..sort(
        (a, b) =>
            a.round.compareTo(
          b.round,
        ),
      );

    final safeCount =
        count.clamp(1, 1000);

    final start =
        sorted.length > safeCount
            ? sorted.length - safeCount
            : 0;

    for (final lotto
        in sorted.sublist(start)) {
      for (final number
          in lotto.numbers) {
        result[number] =
            (result[number] ?? 0) + 1;
      }
    }

    return result;
  }

  Map<int, int> _overdueMap(
    List<LottoResult> history,
  ) {
    final result =
        <int, int>{};

    if (history.isEmpty) {
      for (var number = 1;
          number <= 45;
          number++) {
        result[number] = 0;
      }

      return result;
    }

    final sorted = [...history]
      ..sort(
        (a, b) =>
            a.round.compareTo(
          b.round,
        ),
      );

    final latestRound =
        sorted.last.round;

    for (var number = 1;
        number <= 45;
        number++) {
      var lastRound = 0;

      for (final lotto in sorted) {
        if (lotto.numbers
            .contains(number)) {
          lastRound = lotto.round;
        }
      }

      result[number] =
          latestRound - lastRound;
    }

    return result;
  }
}