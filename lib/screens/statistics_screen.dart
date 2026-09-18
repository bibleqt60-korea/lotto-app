import 'package:flutter/material.dart';

import '../models/lotto_result.dart';
import '../models/statistics_result.dart';
import '../services/lotto_repository.dart';
import '../services/statistics_service.dart';
import '../utils/lotto_calculator.dart';
import '../widgets/common_widgets.dart';
import '../widgets/lotto_ball.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState
    extends State<StatisticsScreen> {
  final LottoRepository _repository =
      LottoRepository.instance;

  final StatisticsService _service =
      StatisticsService();

  List<LottoResult> _results = [];
  List<StatisticsResult> _statistics = [];

  bool _loading = true;
  int _recentRounds = 20;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results =
        await _repository.getAll();

    final statistics = _service.calculate(
      results,
      recentRounds: _recentRounds,
    );

    if (!mounted) return;

    setState(() {
      _results = results;
      _statistics = statistics;
      _loading = false;
    });
  }

  void _showInfo(
    String title,
    String message,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingMessage();
    }

    if (_results.isEmpty) {
      return const EmptyMessage(
        message:
            '통계 데이터가 없습니다.\n'
            '홈에서 새로고침해주세요.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '통계',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(),
          const SizedBox(height: 12),
          _buildFrequency(),
          const SizedBox(height: 12),
          _buildRecent(),
          const SizedBox(height: 12),
          _buildOverdue(),
          const SizedBox(height: 12),
          _buildOddEven(),
          const SizedBox(height: 12),
          _buildSum(),
          const SizedBox(height: 12),
          _buildAc(),
          const SizedBox(height: 12),
          _buildRange(),
          const SizedBox(height: 12),
          _buildConsecutive(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final latest =
        _service.getLatestRound(_results);

    final averageSum =
        _results.isEmpty
            ? 0.0
            : _results
                    .map(
                      (result) =>
                          LottoCalculator.sum(
                        result.numbers,
                      ),
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                _results.length;

    return _buildExpandableCard(
      title: '통계 요약',
      infoTitle: '통계 요약',
      infoMessage:
          '현재 앱에 저장된 로또 데이터를 '
          '간단하게 보여주는 화면입니다.\n\n'
          '분석 회차: 통계에 사용한 로또 회차 수\n'
          '최신 회차: 가장 최근에 저장된 회차\n'
          '평균 번호 합계: 당첨번호 6개를 더한 값의 평균',
      children: [
        Text(
          '분석 회차: ${_results.length}회',
        ),
        const SizedBox(height: 6),
        Text(
          '최신 회차: $latest회',
        ),
        const SizedBox(height: 6),
        Text(
          '평균 번호 합계: '
          '${averageSum.toStringAsFixed(1)}',
        ),
      ],
    );
  }

  Widget _buildFrequency() {
    final sorted =
        _service.sortByAppearance(
      _statistics,
    );

    return _buildNumberList(
      title: '전체 출현 빈도 TOP 10',
      infoTitle: '전체 출현 빈도',
      infoMessage:
          '지금까지의 모든 로또 회차에서 '
          '각 번호가 몇 번 당첨되었는지를 보여줍니다.\n\n'
          '위쪽에 있을수록 과거에 자주 등장한 번호입니다.',
      items: sorted.take(10).toList(),
      value: (item) =>
          '${item.appearanceCount}회',
    );
  }

  Widget _buildRecent() {
    final sorted =
        _service.sortByRecent(
      _statistics,
    );

    return _buildExpandableCard(
      title: '최근 출현 빈도',
      infoTitle: '최근 출현 빈도',
      infoMessage:
          '최근 몇 회의 당첨번호에서 '
          '각 번호가 몇 번 나왔는지를 보여줍니다.\n\n'
          '오른쪽에서 최근 5회, 10회, 20회, '
          '30회 중 원하는 기간을 선택할 수 있습니다.',
      trailing: DropdownButton<int>(
        value: _recentRounds,
        items: const [
          DropdownMenuItem(
            value: 5,
            child: Text('최근 5회'),
          ),
          DropdownMenuItem(
            value: 10,
            child: Text('최근 10회'),
          ),
          DropdownMenuItem(
            value: 20,
            child: Text('최근 20회'),
          ),
          DropdownMenuItem(
            value: 30,
            child: Text('최근 30회'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;

          setState(() {
            _recentRounds = value;
          });

          _load();
        },
      ),
      children: [
        ...sorted.take(10).map(
          (item) => _numberRow(
            item.number,
            '${item.recentAppearanceCount}회',
          ),
        ),
      ],
    );
  }

  Widget _buildOverdue() {
    final sorted =
        _service.sortByOverdue(
      _statistics,
    );

    return _buildNumberList(
      title: '미출현 기간 TOP 10',
      infoTitle: '미출현 기간',
      infoMessage:
          '각 번호가 마지막으로 나온 뒤 '
          '몇 회 동안 나오지 않았는지를 보여줍니다.\n\n'
          '위쪽에 있을수록 오랫동안 나오지 않은 번호입니다.',
      items: sorted.take(10).toList(),
      value: (item) =>
          '${item.overdueCount}회차',
    );
  }

  Widget _buildNumberList({
    required String title,
    required String infoTitle,
    required String infoMessage,
    required List<StatisticsResult> items,
    required String Function(
      StatisticsResult,
    ) value,
  }) {
    return _buildExpandableCard(
      title: title,
      infoTitle: infoTitle,
      infoMessage: infoMessage,
      children: [
        ...items.asMap().entries.map(
          (entry) {
            final rank = entry.key + 1;
            final item = entry.value;

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                child: Text('$rank'),
              ),
              title: Row(
                children: [
                  LottoBall(
                    number: item.number,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.number}번',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Text(value(item)),
            );
          },
        ),
      ],
    );
  }

  Widget _numberRow(
    int number,
    String value,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: LottoBall(
        number: number,
        size: 32,
      ),
      title: Text('$number번'),
      trailing: Text(value),
    );
  }

  Widget _buildOddEven() {
    var odd = 0;
    var even = 0;

    for (final result in _results) {
      odd += result.numbers
          .where((number) => number.isOdd)
          .length;

      even += result.numbers
          .where((number) => number.isEven)
          .length;
    }

    final total = odd + even;

    return _buildStatCard(
      title: '홀수 / 짝수',
      infoTitle: '홀수 / 짝수',
      infoMessage:
          '전체 당첨번호에서 홀수와 짝수가 '
          '얼마나 등장했는지를 보여줍니다.\n\n'
          '홀수: 1, 3, 5, 7처럼 2로 나누어떨어지지 않는 번호\n'
          '짝수: 2, 4, 6, 8처럼 2로 나누어떨어지는 번호',
      children: [
        _percentageRow(
          '홀수',
          odd,
          total,
        ),
        _percentageRow(
          '짝수',
          even,
          total,
        ),
      ],
    );
  }

  Widget _percentageRow(
    String title,
    int count,
    int total,
  ) {
    final percent =
        total == 0
            ? 0.0
            : count / total * 100;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(title),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value:
                  total == 0
                      ? 0
                      : count / total,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count회 '
            '(${percent.toStringAsFixed(1)}%)',
          ),
        ],
      ),
    );
  }

  Widget _buildSum() {
    final sums = _results.map(
      (result) =>
          LottoCalculator.sum(
        result.numbers,
      ),
    );

    final average =
        sums.reduce((a, b) => a + b) /
            _results.length;

    final min =
        sums.reduce(
          (a, b) => a < b ? a : b,
        );

    final max =
        sums.reduce(
          (a, b) => a > b ? a : b,
        );

    return _buildStatCard(
      title: '번호 합계 분석',
      infoTitle: '번호 합계 분석',
      infoMessage:
          '한 회차의 당첨번호 6개를 모두 더한 값을 분석합니다.\n\n'
          '예: 3, 7, 12, 20, 31, 40이라면 '
          '합계는 113입니다.\n\n'
          '평균은 전체 회차의 평균 합계, '
          '최저와 최고는 지금까지 나온 가장 낮은 값과 높은 값입니다.',
      children: [
        _infoRow(
          '평균',
          average.toStringAsFixed(1),
        ),
        _infoRow('최저', '$min'),
        _infoRow('최고', '$max'),
      ],
    );
  }

  Widget _buildAc() {
    final values = _results.map(
      (result) =>
          LottoCalculator.acValue(
        result.numbers,
      ),
    );

    final average =
        values.reduce((a, b) => a + b) /
            _results.length;

    final min =
        values.reduce(
          (a, b) => a < b ? a : b,
        );

    final max =
        values.reduce(
          (a, b) => a > b ? a : b,
        );

    return _buildStatCard(
      title: 'AC 값 분석',
      infoTitle: 'AC 값',
      infoMessage:
          'AC 값은 6개 번호 사이의 차이를 이용해 '
          '번호 조합의 복잡한 정도를 나타내는 통계입니다.\n\n'
          '번호가 서로 비슷하게 몰려 있으면 낮아지고, '
          '서로 다른 간격의 번호가 섞이면 높아지는 경향이 있습니다.\n\n'
          '로또 당첨을 보장하는 지표는 아니며 '
          '번호 조합을 살펴보는 참고용 통계입니다.',
      children: [
        _infoRow(
          '평균',
          average.toStringAsFixed(1),
        ),
        _infoRow('최저', '$min'),
        _infoRow('최고', '$max'),
      ],
    );
  }

  Widget _buildRange() {
    final ranges = <String, int>{
      '1~9': 0,
      '10~18': 0,
      '19~27': 0,
      '28~36': 0,
      '37~45': 0,
    };

    for (final result in _results) {
      for (final number in result.numbers) {
        if (number <= 9) {
          ranges['1~9'] =
              ranges['1~9']! + 1;
        } else if (number <= 18) {
          ranges['10~18'] =
              ranges['10~18']! + 1;
        } else if (number <= 27) {
          ranges['19~27'] =
              ranges['19~27']! + 1;
        } else if (number <= 36) {
          ranges['28~36'] =
              ranges['28~36']! + 1;
        } else {
          ranges['37~45'] =
              ranges['37~45']! + 1;
        }
      }
    }

    final total =
        _results.length * 6;

    return _buildStatCard(
      title: '번호 구간 분포',
      infoTitle: '번호 구간 분포',
      infoMessage:
          '1~45번을 5개 구간으로 나누어 '
          '각 구간의 번호가 얼마나 등장했는지 보여줍니다.\n\n'
          '1~9 / 10~18 / 19~27 / 28~36 / 37~45\n\n'
          '어떤 번호대가 상대적으로 많이 또는 적게 '
          '등장했는지 확인할 수 있습니다.',
      children: [
        ...ranges.entries.map(
          (entry) {
            final ratio =
                total == 0
                    ? 0.0
                    : entry.value / total;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    child:
                        LinearProgressIndicator(
                      value: ratio,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value}회',
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConsecutive() {
    final sorted =
        _service.sortByConsecutive(
      _statistics,
    );

    return _buildNumberList(
      title: '연속 출현 빈도 TOP 10',
      infoTitle: '연속 출현 빈도',
      infoMessage:
          '어떤 번호가 이전 회차에 이어 '
          '다음 회차에도 연속해서 등장한 횟수를 보여줍니다.\n\n'
          '예: 7번이 연속된 회차의 당첨번호에 '
          '등장했다면 연속 출현으로 계산합니다.',
      items: sorted.take(10).toList(),
      value: (item) =>
          '${item.consecutiveCount}회',
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required List<Widget> children,
    String? infoTitle,
    String? infoMessage,
    Widget? trailing,
  }) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (infoTitle != null &&
                infoMessage != null)
              IconButton(
                tooltip: '설명',
                onPressed: () => _showInfo(
                  infoTitle,
                  infoMessage,
                ),
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                ),
              ),
          ],
        ),
        trailing: trailing == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  trailing,
                  const Icon(
                    Icons.expand_more,
                  ),
                ],
              ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: children,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required List<Widget> children,
    String? infoTitle,
    String? infoMessage,
  }) {
    return _buildExpandableCard(
      title: title,
      infoTitle: infoTitle,
      infoMessage: infoMessage,
      children: children,
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}