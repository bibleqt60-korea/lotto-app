class LottoCalculator {
  static int sum(List<int> numbers) {
    return numbers.fold(
      0,
      (total, number) => total + number,
    );
  }

  static int oddCount(List<int> numbers) {
    return numbers
        .where((number) => number.isOdd)
        .length;
  }

  static int evenCount(List<int> numbers) {
    return numbers
        .where((number) => number.isEven)
        .length;
  }

  static Map<String, int> lowHighCount(
    List<int> numbers,
  ) {
    final low = numbers
        .where((number) => number <= 22)
        .length;

    return {
      'low': low,
      'high': numbers.length - low,
    };
  }

  static int acValue(List<int> numbers) {
    final sorted = [...numbers]..sort();

    final differences = <int>{};

    for (var i = 0; i < sorted.length; i++) {
      for (var j = i + 1;
          j < sorted.length;
          j++) {
        differences.add(
          sorted[j] - sorted[i],
        );
      }
    }

    return differences.length -
        (sorted.length - 1);
  }

  static int consecutivePairs(
    List<int> numbers,
  ) {
    final sorted = [...numbers]..sort();
    var count = 0;

    for (var i = 0;
        i < sorted.length - 1;
        i++) {
      if (sorted[i + 1] ==
          sorted[i] + 1) {
        count++;
      }
    }

    return count;
  }

  static int maxEndingDigitCount(
    List<int> numbers,
  ) {
    final counts = <int, int>{};

    for (final number in numbers) {
      final ending = number % 10;

      counts[ending] =
          (counts[ending] ?? 0) + 1;
    }

    if (counts.isEmpty) {
      return 0;
    }

    return counts.values.reduce(
      (a, b) => a > b ? a : b,
    );
  }

  static int primeCount(List<int> numbers) {
    return numbers
        .where(_isPrime)
        .length;
  }

  static bool _isPrime(int number) {
    if (number < 2) {
      return false;
    }

    for (var i = 2;
        i * i <= number;
        i++) {
      if (number % i == 0) {
        return false;
      }
    }

    return true;
  }

  static bool matchesRangePattern(
    List<int> numbers,
    List<int> pattern,
  ) {
    if (pattern.length != 5) {
      return true;
    }

    final counts = [
      0,
      0,
      0,
      0,
      0,
    ];

    for (final number in numbers) {
      if (number <= 10) {
        counts[0]++;
      } else if (number <= 20) {
        counts[1]++;
      } else if (number <= 30) {
        counts[2]++;
      } else if (number <= 40) {
        counts[3]++;
      } else {
        counts[4]++;
      }
    }

    for (var i = 0; i < 5; i++) {
      if (pattern[i] >= 0 &&
          pattern[i] != counts[i]) {
        return false;
      }
    }

    return true;
  }

  static int countMatches(
    List<int> myNumbers,
    List<int> winningNumbers,
  ) {
    return myNumbers
        .where(winningNumbers.contains)
        .length;
  }

  static int getRank(
    List<int> myNumbers,
    List<int> winningNumbers,
    int bonusNumber,
  ) {
    final matches = countMatches(
      myNumbers,
      winningNumbers,
    );

    final hasBonus =
        myNumbers.contains(bonusNumber);

    if (matches == 6) {
      return 1;
    }

    if (matches == 5 && hasBonus) {
      return 2;
    }

    if (matches == 5) {
      return 3;
    }

    if (matches == 4) {
      return 4;
    }

    if (matches == 3) {
      return 5;
    }

    return 0;
  }

  static String formatPrize(int prize) {
    if (prize <= 0) {
      return '0';
    }

    return prize
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }
}