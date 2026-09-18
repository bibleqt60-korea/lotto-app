import 'package:flutter/material.dart';

import '../models/my_lotto_number.dart';
import '../services/lotto_repository.dart';
import '../services/my_number_service.dart';
import '../utils/lotto_calculator.dart';
import '../widgets/common_widgets.dart';
import '../widgets/lotto_ball.dart';

class MyNumbersScreen extends StatefulWidget {
  const MyNumbersScreen({super.key});

  @override
  MyNumbersScreenState createState() =>
      MyNumbersScreenState();
}

class MyNumbersScreenState
    extends State<MyNumbersScreen> {
  final MyNumberService _service =
      MyNumberService();

  final LottoRepository _lottoRepository =
      LottoRepository.instance;

  List<MyLottoNumber> _numbers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> reload() async {
    await _load();
  }

  Future<void> _load() async {
    final numbers = await _service.getAll();

    if (!mounted) {
      return;
    }

    setState(() {
      _numbers = numbers;
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

  Future<void> _delete(
    MyLottoNumber item,
  ) async {
    await _service.delete(item.id);
    await _load();
  }

  Future<void> _editMemo(
    MyLottoNumber item,
  ) async {
    final controller =
        TextEditingController(text: item.memo);

    final memo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모 수정'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '메모를 입력하세요.',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (memo == null) {
      return;
    }

    await _service.update(
      item.copyWith(memo: memo),
    );

    await _load();
  }

  Future<void> _deleteAll() async {
    if (_numbers.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('전체 삭제'),
          content: const Text(
            '저장된 모든 번호를 삭제할까요?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _service.clear();
    await _load();
  }

  Future<void> _checkWinning(
    MyLottoNumber item,
  ) async {
    final latest =
        await _lottoRepository.getLatestLocal();

    if (latest == null) {
      _showMessage('당첨번호 데이터가 없습니다.');
      return;
    }

    final result = _service.checkWinning(
      item.numbers,
      latest,
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final rank = result['rank'] as int;
        final matches =
            result['matchCount'] as int;
        final bonus = result['bonus'] as bool;
        final prize = result['prize'] as int;

        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${latest.round}회 당첨 확인',
                ),
              ),
              IconButton(
                tooltip: '당첨 기준 설명',
                onPressed: () => _showInfo(
                  '당첨 기준',
                  '1등: 당첨번호 6개 모두 일치\n'
                  '2등: 당첨번호 5개 + 보너스 번호 일치\n'
                  '3등: 당첨번호 5개 일치\n'
                  '4등: 당첨번호 4개 일치\n'
                  '5등: 당첨번호 3개 일치',
                ),
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                children: item.numbers
                    .map(
                      (number) => LottoBall(
                        number: number,
                        size: 36,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Text(
                rank > 0
                    ? '$rank등 당첨!'
                    : '당첨되지 않았습니다.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      rank > 0 ? Colors.red : null,
                ),
              ),
              const SizedBox(height: 10),
              Text('일치 번호: $matches개'),
              if (bonus)
                const Text('보너스 번호 포함'),
              if (rank > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '당첨금: '
                  '${LottoCalculator.formatPrize(prize)}원',
                ),
              ],
            ],
          ),
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

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              '내 번호',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              tooltip: '내 번호 설명',
              onPressed: () => _showInfo(
                '내 번호',
                '번호 생성 화면에서 저장한 번호를 '
                '모아볼 수 있는 공간입니다.\n\n'
                '저장한 번호의 통계 확인, '
                '당첨 확인, 메모 수정, 삭제가 가능합니다.',
              ),
              icon: const Icon(
                Icons.info_outline,
                size: 20,
              ),
            ),
          ],
        ),
        actions: [
          if (_numbers.isNotEmpty)
            IconButton(
              tooltip: '전체 삭제',
              onPressed: _deleteAll,
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
        ],
      ),
      body: _loading
          ? const LoadingMessage()
          : _numbers.isEmpty
              ? const EmptyMessage(
                  message:
                      '저장된 번호가 없습니다.\n'
                      '번호 생성에서 번호를 저장해 보세요.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _numbers.length,
                  itemBuilder: (context, index) {
                    return _buildNumberCard(
                      _numbers[index],
                    );
                  },
                ),
    );
  }

  Widget _buildNumberCard(
    MyLottoNumber item,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity:
                      VisualDensity.compact,
                  tooltip: '당첨 확인',
                  onPressed: () =>
                      _checkWinning(item),
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                  ),
                ),
                IconButton(
                  visualDensity:
                      VisualDensity.compact,
                  tooltip: '메모 수정',
                  onPressed: () =>
                      _editMemo(item),
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),
                IconButton(
                  visualDensity:
                      VisualDensity.compact,
                  tooltip: '삭제',
                  onPressed: () =>
                      _delete(item),
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.numbers.map(
                (number) {
                  return LottoBall(
                    number: number,
                    size: 40,
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '합계 ${LottoCalculator.sum(item.numbers)}'
                    ' · AC ${LottoCalculator.acValue(item.numbers)}'
                    ' · 홀 ${LottoCalculator.oddCount(item.numbers)}'
                    ' · 짝 ${LottoCalculator.evenCount(item.numbers)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity:
                      VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  tooltip: '통계 설명',
                  onPressed: () => _showInfo(
                    '번호 통계',
                    '합계: 6개 번호를 모두 더한 값\n'
                    'AC: 번호 조합의 복잡도를 나타내는 값\n'
                    '홀: 홀수 번호의 개수\n'
                    '짝: 짝수 번호의 개수',
                  ),
                  icon: const Icon(
                    Icons.info_outline,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (item.memo.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.memo),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}