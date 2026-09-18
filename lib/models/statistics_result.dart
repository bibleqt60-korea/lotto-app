class StatisticsResult {
  final int number;
  final int appearanceCount;
  final int recentAppearanceCount;
  final int consecutiveCount;
  final int overdueCount;
  final int lastAppearanceRound;

  const StatisticsResult({
    required this.number,
    required this.appearanceCount,
    required this.recentAppearanceCount,
    required this.consecutiveCount,
    required this.overdueCount,
    required this.lastAppearanceRound,
  });

  double get appearanceRate {
    return appearanceCount.toDouble();
  }

  StatisticsResult copyWith({
    int? number,
    int? appearanceCount,
    int? recentAppearanceCount,
    int? consecutiveCount,
    int? overdueCount,
    int? lastAppearanceRound,
  }) {
    return StatisticsResult(
      number: number ?? this.number,
      appearanceCount:
          appearanceCount ?? this.appearanceCount,
      recentAppearanceCount:
          recentAppearanceCount ??
              this.recentAppearanceCount,
      consecutiveCount:
          consecutiveCount ?? this.consecutiveCount,
      overdueCount:
          overdueCount ?? this.overdueCount,
      lastAppearanceRound:
          lastAppearanceRound ??
              this.lastAppearanceRound,
    );
  }
}

class OddEvenStatistics {
  final int odd;
  final int even;

  const OddEvenStatistics({
    required this.odd,
    required this.even,
  });

  int get total => odd + even;

  double get oddPercent {
    if (total == 0) {
      return 0;
    }

    return odd / total * 100;
  }

  double get evenPercent {
    if (total == 0) {
      return 0;
    }

    return even / total * 100;
  }
}

class RangeStatistics {
  final Map<String, int> ranges;

  const RangeStatistics({
    required this.ranges,
  });

  int get total {
    return ranges.values.fold(
      0,
      (sum, value) => sum + value,
    );
  }
}