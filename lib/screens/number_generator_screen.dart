import 'package:flutter/material.dart';

import '../models/lotto_result.dart';
import '../services/lotto_repository.dart';
import '../services/my_number_service.dart';
import '../services/number_generator_service.dart';
import '../utils/lotto_calculator.dart';
import '../widgets/common_widgets.dart';
import '../widgets/lotto_ball.dart';

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() =>
      _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState
    extends State<NumberGeneratorScreen> {
  final LottoRepository _lottoRepository =
      LottoRepository.instance;

  final MyNumberService _myNumberService =
      MyNumberService();

  final NumberGeneratorService _generator =
      NumberGeneratorService();

  int _gameCount = 5;

  bool _useFrequency = false;
  int _frequencyMin = 0;
  int _frequencyMax = 999;

  bool _useRecent = false;
  int _recentGames = 10;
  int _recentMin = 0;
  int _recentMax = 10;

  bool _useOverdue = false;
  int _overdueMin = 0;
  int _overdueMax = 999;

  bool _useOddEven = false;
  int _oddCount = 3;

  bool _useLowHigh = false;
  int _lowCount = 3;

  bool _useSum = false;
  double _minSum = 100;
  double _maxSum = 200;

  bool _useAc = false;
  double _minAc = 7;
  double _maxAc = 15;

  bool _useConsecutive = false;
  int _minConsecutive = 0;
  int _maxConsecutive = 2;

  bool _useEnding = false;
  int _maxSameEnding = 2;

  bool _useRange = false;

  final List<int> _rangePattern =
      [-1, -1, -1, -1, -1];

  bool _usePrime = false;
  int _minPrime = 0;
  int _maxPrime = 6;

  bool _usePreviousOverlap = false;
  int _maxPreviousOverlap = 2;

  final Set<int> _fixedNumbers = {};
  final Set<int> _excludedNumbers = {};

  List<List<int>> _generated = [];
  List<LottoResult> _history = [];

  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history =
        await _lottoRepository.getAllLocal();

    if (!mounted) return;

    setState(() {
      _history = history;
      _loading = false;
    });
  }

  NumberGeneratorSettings _settings() {
    return NumberGeneratorSettings(
      useFrequency: _useFrequency,
      frequencyMin: _frequencyMin,
      frequencyMax: _frequencyMax,
      useRecent: _useRecent,
      recentGames: _recentGames,
      recentMin: _recentMin,
      recentMax: _recentMax,
      useOverdue: _useOverdue,
      overdueMin: _overdueMin,
      overdueMax: _overdueMax,
      useOddEven: _useOddEven,
      oddCount: _oddCount,
      useLowHigh: _useLowHigh,
      lowCount: _lowCount,
      useSum: _useSum,
      minSum: _minSum.round(),
      maxSum: _maxSum.round(),
      useAc: _useAc,
      minAc: _minAc.round(),
      maxAc: _maxAc.round(),
      useConsecutive: _useConsecutive,
      minConsecutive: _minConsecutive,
      maxConsecutive: _maxConsecutive,
      useEnding: _useEnding,
      maxSameEnding: _maxSameEnding,
      useRange: _useRange,
      rangePattern:
          List<int>.from(_rangePattern),
      usePrime: _usePrime,
      minPrime: _minPrime,
      maxPrime: _maxPrime,
      usePreviousOverlap:
          _usePreviousOverlap,
      maxPreviousOverlap:
          _maxPreviousOverlap,
      fixedNumbers:
          _fixedNumbers.toList(),
      excludedNumbers:
          _excludedNumbers.toList(),
    );
  }

  Future<void> _generate() async {
    if (_generating) return;

    if (_history.isEmpty) {
      _showMessage(
        '로또 데이터를 먼저 가져와 주세요.',
      );
      return;
    }

    setState(() {
      _generating = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 50),
    );

    final numbers =
        _generator.generateMultiple(
      count: _gameCount,
      history: _history,
      settings: _settings(),
    );

    if (!mounted) return;

    setState(() {
      _generated = numbers;
      _generating = false;
    });

    if (numbers.length < _gameCount) {
      _showMessage(
        '조건이 너무 많거나 범위가 좁습니다.\n'
        '조건을 조금 완화해 주세요.',
      );
    }
  }

  Future<void> _saveNumber(
    List<int> numbers,
  ) async {
    await _myNumberService.save(numbers);

    if (!mounted) return;

    _showMessage('내 번호에 저장했습니다.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  int get _activeConditionCount {
    var count = 0;

    if (_useFrequency) count++;
    if (_useRecent) count++;
    if (_useOverdue) count++;
    if (_useOddEven) count++;
    if (_useLowHigh) count++;
    if (_useSum) count++;
    if (_useAc) count++;
    if (_useConsecutive) count++;
    if (_useEnding) count++;
    if (_useRange) count++;
    if (_usePrime) count++;
    if (_usePreviousOverlap) count++;
    if (_fixedNumbers.isNotEmpty) count++;
    if (_excludedNumbers.isNotEmpty) count++;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '번호 생성',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const LoadingMessage()
          : ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [
                _buildBasicSettings(),
                const SizedBox(height: 12),
                _buildResults(),
                const SizedBox(height: 12),
                _buildAdvancedSettings(),
              ],
            ),
    );
  }

  Widget _buildBasicSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '번호 생성',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text('생성 게임 수'),
                ),
                DropdownButton<int>(
                  value: _gameCount,
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('1게임'),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text('5게임'),
                    ),
                    DropdownMenuItem(
                      value: 10,
                      child: Text('10게임'),
                    ),
                    DropdownMenuItem(
                      value: 20,
                      child: Text('20게임'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _gameCount = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _generating
                        ? null
                        : _generate,
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                      ),
                label: Text(
                  _generating
                      ? '생성 중...'
                      : '번호 생성',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: const Text(
          '⚙ 고급 설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _activeConditionCount == 0
              ? '조건 없이 번호 생성'
              : '고급 설정 $_activeConditionCount개 적용 중',
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          _buildStatisticsSettings(),
          _buildStructureSettings(),
          _buildNumberSettings(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSettings() {
    return ExpansionTile(
      title: const Text('통계 조건'),
      initiallyExpanded: false,
      children: [
        _switchTile(
          '전체 출현 빈도',
          _useFrequency,
          (value) {
            setState(() {
              _useFrequency = value;
            });
          },
          info: '지금까지의 모든 로또 회차에서 '
              '각 번호가 몇 번 나왔는지를 기준으로 합니다.\n\n'
              '원하는 출현 횟수 범위를 정해 '
              '그 범위에 들어오는 번호만 사용합니다.',
        ),
        if (_useFrequency)
          _buildFrequencyDetail(),
        _switchTile(
          '최근 출현 빈도',
          _useRecent,
          (value) {
            setState(() {
              _useRecent = value;
            });
          },
          info: '최근 몇 회의 당첨번호만 살펴봅니다.\n\n'
              '최근에 자주 나온 번호 또는 '
              '적게 나온 번호를 골라 번호 생성에 사용할 수 있습니다.',
        ),
        if (_useRecent)
          _buildRecentDetail(),
        _switchTile(
          '미출현 기간',
          _useOverdue,
          (value) {
            setState(() {
              _useOverdue = value;
            });
          },
          info: '각 번호가 마지막으로 나온 뒤 '
              '몇 회 동안 나오지 않았는지를 봅니다.\n\n'
              '오랫동안 나오지 않은 번호를 '
              '선택하는 데 사용할 수 있습니다.',
        ),
        if (_useOverdue)
          _buildOverdueDetail(),
      ],
    );
  }

  Widget _buildFrequencyDetail() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '각 번호의 전체 출현 횟수 범위',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _rangeSlider(
          title: '출현 횟수',
          min: 0,
          max: 300,
          start:
              _frequencyMin.toDouble(),
          end:
              _frequencyMax > 300
                  ? 300
                  : _frequencyMax.toDouble(),
          divisions: 300,
          onChanged: (values) {
            setState(() {
              _frequencyMin =
                  values.start.round();
              _frequencyMax =
                  values.end.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildRecentDetail() {
    return Column(
      children: [
        _numberSelector(
          title: '최근 몇 회 분석',
          value: _recentGames,
          min: 5,
          max: 30,
          onChanged: (value) {
            setState(() {
              _recentGames = value;
              if (_recentMax > value) {
                _recentMax = value;
              }
            });
          },
        ),
        _rangeSlider(
          title: '최근 출현 횟수',
          min: 0,
          max: _recentGames.toDouble(),
          start: _recentMin.toDouble(),
          end: _recentMax
              .clamp(
                _recentMin,
                _recentGames,
              )
              .toDouble(),
          divisions: _recentGames,
          onChanged: (values) {
            setState(() {
              _recentMin =
                  values.start.round();
              _recentMax =
                  values.end.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildOverdueDetail() {
    return _rangeSlider(
      title: '미출현 회차',
      min: 0,
      max: 100,
      start: _overdueMin.toDouble(),
      end:
          _overdueMax > 100
              ? 100
              : _overdueMax.toDouble(),
      divisions: 100,
      onChanged: (values) {
        setState(() {
          _overdueMin =
              values.start.round();
          _overdueMax =
              values.end.round();
        });
      },
    );
  }

  Widget _buildStructureSettings() {
    return ExpansionTile(
      title: const Text('번호 구조 조건'),
      initiallyExpanded: false,
      children: [
        _switchTile(
          '홀짝 비율',
          _useOddEven,
          (value) {
            setState(() {
              _useOddEven = value;
            });
          },
          info: '생성할 번호 6개 중 '
              '홀수와 짝수의 개수를 정합니다.\n\n'
              '예: 홀수 3개라면 '
              '홀수 3개 + 짝수 3개 조건으로 생성합니다.',
        ),
        if (_useOddEven)
          _numberSelector(
            title: '홀수 개수',
            value: _oddCount,
            min: 0,
            max: 6,
            onChanged: (value) {
              setState(() {
                _oddCount = value;
              });
            },
          ),
        _switchTile(
          '저·고 번호 비율',
          _useLowHigh,
          (value) {
            setState(() {
              _useLowHigh = value;
            });
          },
          info: '1~22번을 낮은 번호, '
              '23~45번을 높은 번호로 나누어 '
              '6개 번호의 비율을 정합니다.',
        ),
        if (_useLowHigh)
          _numberSelector(
            title: '1~22 번호 개수',
            value: _lowCount,
            min: 0,
            max: 6,
            onChanged: (value) {
              setState(() {
                _lowCount = value;
              });
            },
          ),
        _switchTile(
          '총합 범위',
          _useSum,
          (value) {
            setState(() {
              _useSum = value;
            });
          },
          info: '선택된 6개 번호를 모두 더한 값입니다.\n\n'
              '예: 3, 7, 12, 25, 31, 40이라면 '
              '총합은 118입니다.',
        ),
        if (_useSum)
          _rangeSlider(
            title: '총합',
            min: 21,
            max: 255,
            start: _minSum,
            end: _maxSum,
            onChanged: (values) {
              setState(() {
                _minSum = values.start;
                _maxSum = values.end;
              });
            },
          ),
        _switchTile(
          'AC 값',
          _useAc,
          (value) {
            setState(() {
              _useAc = value;
            });
          },
          info: '6개 번호 사이의 차이를 이용해 '
              '번호 조합의 복잡한 정도를 나타내는 값입니다.\n\n'
              '일반적인 번호 조합이 어느 정도인지 '
              '확인할 때 사용하는 통계입니다.',
        ),
        if (_useAc)
          _rangeSlider(
            title: 'AC',
            min: 0,
            max: 15,
            start: _minAc,
            end: _maxAc,
            divisions: 15,
            onChanged: (values) {
              setState(() {
                _minAc = values.start;
                _maxAc = values.end;
              });
            },
          ),
        _switchTile(
          '연속번호',
          _useConsecutive,
          (value) {
            setState(() {
              _useConsecutive = value;
            });
          },
          info: '연속해서 붙어 있는 번호의 개수를 '
              '조건으로 설정합니다.\n\n'
              '예: 10, 11이 있으면 연속쌍 1개입니다.\n'
              '10, 11, 12가 있으면 연속쌍 2개입니다.',
        ),
        if (_useConsecutive) ...[
          _numberSelector(
            title: '최소 연속쌍',
            value: _minConsecutive,
            min: 0,
            max: 5,
            onChanged: (value) {
              setState(() {
                _minConsecutive = value;
              });
            },
          ),
          _numberSelector(
            title: '최대 연속쌍',
            value: _maxConsecutive,
            min: 0,
            max: 5,
            onChanged: (value) {
              setState(() {
                _maxConsecutive = value;
              });
            },
          ),
        ],
        _switchTile(
          '끝수 중복',
          _useEnding,
          (value) {
            setState(() {
              _useEnding = value;
            });
          },
          info: '번호의 마지막 숫자가 같은 경우를 '
              '확인하는 조건입니다.\n\n'
              '예: 3, 13, 23은 모두 끝수가 3입니다.',
        ),
        if (_useEnding)
          _numberSelector(
            title: '같은 끝수 최대',
            value: _maxSameEnding,
            min: 1,
            max: 6,
            onChanged: (value) {
              setState(() {
                _maxSameEnding = value;
              });
            },
          ),
        _switchTile(
          '구간 분포',
          _useRange,
          (value) {
            setState(() {
              _useRange = value;
            });
          },
          info: '1~45번을 5개 구간으로 나누어 '
              '각 구간에서 몇 개를 뽑을지 정합니다.\n\n'
              '1~9 / 10~18 / 19~27 / 28~36 / 37~45',
        ),
        if (_useRange)
          _buildRangePatternPicker(),
        _switchTile(
          '소수 개수',
          _usePrime,
          (value) {
            setState(() {
              _usePrime = value;
            });
          },
          info: '1~45 사이의 소수가 몇 개 포함되는지를 '
              '조건으로 설정합니다.\n\n'
              '소수 예: 2, 3, 5, 7, 11, 13',
        ),
        if (_usePrime) ...[
          _numberSelector(
            title: '최소 소수',
            value: _minPrime,
            min: 0,
            max: 6,
            onChanged: (value) {
              setState(() {
                _minPrime = value;
              });
            },
          ),
          _numberSelector(
            title: '최대 소수',
            value: _maxPrime,
            min: 0,
            max: 6,
            onChanged: (value) {
              setState(() {
                _maxPrime = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRangePatternPicker() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          '구간별 번호 개수',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '1~9 / 10~18 / 19~27 / 28~36 / 37~45',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              List.generate(5, (index) {
            final value =
                _rangePattern[index];

            return Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 2,
                ),
                child:
                    DropdownButton<int>(
                  isExpanded: true,
                  value: value,
                  items: [
                    const DropdownMenuItem(
                      value: -1,
                      child: Text('전체'),
                    ),
                    ...List.generate(
                      7,
                      (number) =>
                          DropdownMenuItem(
                        value: number,
                        child:
                            Text('$number'),
                      ),
                    ),
                  ],
                  onChanged:
                      (selected) {
                    if (selected == null) {
                      return;
                    }

                    setState(() {
                      _rangePattern[index] =
                          selected;
                    });
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNumberSettings() {
    return ExpansionTile(
      title: const Text('중복 / 기타 조건'),
      initiallyExpanded: false,
      children: [
        _switchTile(
          '직전 회차 중복 제한',
          _usePreviousOverlap,
          (value) {
            setState(() {
              _usePreviousOverlap =
                  value;
            });
          },
          info: '가장 최근 당첨번호와 '
              '같은 번호가 몇 개까지 포함될 수 있는지 정합니다.',
        ),
        if (_usePreviousOverlap)
          _numberSelector(
            title: '직전 회차 최대 중복',
            value: _maxPreviousOverlap,
            min: 0,
            max: 6,
            onChanged: (value) {
              setState(() {
                _maxPreviousOverlap =
                    value;
              });
            },
          ),
        _buildNumberPicker(
          title: '고정 번호',
          selected: _fixedNumbers,
          onChanged: () {
            setState(() {});
          },
          info: '내가 반드시 포함하고 싶은 번호입니다.\n\n'
              '예: 7번을 고정하면 '
              '생성되는 모든 조합에 7번이 포함됩니다.',
        ),
        _buildNumberPicker(
          title: '제외 번호',
          selected: _excludedNumbers,
          onChanged: () {
            setState(() {});
          },
          info: '번호 생성에서 제외하고 싶은 번호입니다.\n\n'
              '예: 7번을 제외하면 '
              '생성되는 조합에 7번이 들어가지 않습니다.',
        ),
      ],
    );
  }

  Widget _buildNumberPicker({
    required String title,
    required Set<int> selected,
    required VoidCallback onChanged,
    required String info,
  }) {
    final sorted =
        selected.toList()..sort();

    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          IconButton(
            tooltip: '설명',
            onPressed: () =>
                _showInfo(title, info),
            icon: const Icon(
              Icons.info_outline,
              size: 20,
            ),
          ),
        ],
      ),
      subtitle: Text(
        selected.isEmpty
            ? '선택 없음'
            : sorted.join(', '),
      ),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children:
              List.generate(45, (index) {
            final number = index + 1;
            final active =
                selected.contains(number);

            return FilterChip(
              label: Text('$number'),
              selected: active,
              onSelected: (value) {
                if (value) {
                  if (selected.length >= 6) {
                    _showMessage(
                      '최대 6개까지 선택할 수 있습니다.',
                    );
                    return;
                  }

                  selected.add(number);
                } else {
                  selected.remove(number);
                }

                onChanged();
              },
            );
          }),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _switchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    String? info,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          if (info != null)
            IconButton(
              tooltip: '설명',
              onPressed: () =>
                  _showInfo(title, info),
              icon: const Icon(
                Icons.info_outline,
                size: 20,
              ),
            ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _numberSelector({
    required String title,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(title),
        ),
        IconButton(
          onPressed: value > min
              ? () =>
                  onChanged(value - 1)
              : null,
          icon: const Icon(
            Icons.remove,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: value < max
              ? () =>
                  onChanged(value + 1)
              : null,
          icon: const Icon(
            Icons.add,
          ),
        ),
      ],
    );
  }

  Widget _rangeSlider({
    required String title,
    required double min,
    required double max,
    required double start,
    required double end,
    required ValueChanged<RangeValues>
        onChanged,
    int? divisions,
  }) {
    final safeStart =
        start.clamp(min, max).toDouble();

    final safeEnd =
        end.clamp(safeStart, max).toDouble();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title),
            ),
            Text(
              '${safeStart.round()} ~ '
              '${safeEnd.round()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            safeStart,
            safeEnd,
          ),
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(
            '${safeStart.round()}',
            '${safeEnd.round()}',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_generated.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: '생성 결과',
      initiallyExpanded: true,
      child: Column(
        children:
            _generated.map((numbers) {
          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 8,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Column(
                children: [
                  Wrap(
                    alignment:
                        WrapAlignment.center,
                    spacing: 5,
                    children:
                        numbers.map(
                      (number) {
                        return LottoBall(
                          number: number,
                          size: 38,
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '합계 '
                    '${LottoCalculator.sum(numbers)}'
                    ' · AC '
                    '${LottoCalculator.acValue(numbers)}'
                    ' · 홀 '
                    '${LottoCalculator.oddCount(numbers)}'
                    ' · 짝 '
                    '${LottoCalculator.evenCount(numbers)}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _saveNumber(numbers),
                    icon: const Icon(
                      Icons
                          .bookmark_add_outlined,
                    ),
                    label: const Text(
                      '내 번호 저장',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}