import '../models/lotto_result.dart';
import '../models/statistics_result.dart';

class StatisticsService {
  List<StatisticsResult> calculate(
    List<LottoResult> results, {
    int recentRounds = 20,
  }) {
    if (results.isEmpty) {
      return [];
    }

    final sorted = [...results]
      ..sort(
        (a, b) => a.round.compareTo(b.round),
      );

    final latestRound = sorted.last.round;

    final recent = sorted.length <= recentRounds
        ? sorted
        : sorted.sublist(
            sorted.length - recentRounds,
          );

    final statistics = <StatisticsResult>[];

    for (var number = 1; number <= 45; number++) {
      var appearanceCount = 0;
      var recentAppearanceCount = 0;
      var consecutiveCount = 0;
      var lastAppearanceRound = 0;

      var previousAppeared = false;

      for (final result in sorted) {
        final appeared =
            result.numbers.contains(number);

        if (appeared) {
          appearanceCount++;
          lastAppearanceRound = result.round;

          if (previousAppeared) {
            consecutiveCount++;
          }
        }

        previousAppeared = appeared;
      }

      for (final result in recent) {
        if (result.numbers.contains(number)) {
          recentAppearanceCount++;
        }
      }

      final overdueCount = lastAppearanceRound == 0
          ? sorted.length
          : latestRound - lastAppearanceRound;

      statistics.add(
        StatisticsResult(
          number: number,
          appearanceCount: appearanceCount,
          recentAppearanceCount:
              recentAppearanceCount,
          consecutiveCount: consecutiveCount,
          overdueCount: overdueCount,
          lastAppearanceRound:
              lastAppearanceRound,
        ),
      );
    }

    return statistics;
  }

  List<StatisticsResult> sortByAppearance(
    List<StatisticsResult> statistics,
  ) {
    return [...statistics]
      ..sort(
        (a, b) {
          final result =
              b.appearanceCount.compareTo(
            a.appearanceCount,
          );

          return result != 0
              ? result
              : a.number.compareTo(b.number);
        },
      );
  }

  List<StatisticsResult> sortByRecent(
    List<StatisticsResult> statistics,
  ) {
    return [...statistics]
      ..sort(
        (a, b) {
          final result =
              b.recentAppearanceCount.compareTo(
            a.recentAppearanceCount,
          );

          return result != 0
              ? result
              : a.number.compareTo(b.number);
        },
      );
  }

  List<StatisticsResult> sortByOverdue(
    List<StatisticsResult> statistics,
  ) {
    return [...statistics]
      ..sort(
        (a, b) {
          final result =
              b.overdueCount.compareTo(
            a.overdueCount,
          );

          return result != 0
              ? result
              : a.number.compareTo(b.number);
        },
      );
  }

  List<StatisticsResult> sortByConsecutive(
    List<StatisticsResult> statistics,
  ) {
    return [...statistics]
      ..sort(
        (a, b) {
          final result =
              b.consecutiveCount.compareTo(
            a.consecutiveCount,
          );

          return result != 0
              ? result
              : a.number.compareTo(b.number);
        },
      );
  }

  StatisticsResult? findNumber(
    List<StatisticsResult> statistics,
    int number,
  ) {
    for (final item in statistics) {
      if (item.number == number) {
        return item;
      }
    }

    return null;
  }

  int getLatestRound(
    List<LottoResult> results,
  ) {
    if (results.isEmpty) {
      return 0;
    }

    return results
        .map((item) => item.round)
        .reduce(
          (a, b) => a > b ? a : b,
        );
  }
}