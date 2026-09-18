import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/winning_store.dart';
import '../services/lotto_repository.dart';
import '../services/winning_store_api_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() =>
      _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final WinningStoreApiService _api =
      WinningStoreApiService();

  List<int> _rounds = [];
  int? _selectedRound;

  List<WinningStore> _firstStores = [];
  List<WinningStore> _secondStores = [];

  bool _loading = true;

  static const int _pageSize = 5;

  int _firstPage = 0;
  int _secondPage = 0;

  static final Uri _storeUrl = Uri.parse(
    'https://www.dhlottery.co.kr/prchsplcsrch/home',
  );

  @override
  void initState() {
    super.initState();
    _loadRounds();
  }

  Future<void> _loadRounds() async {
    try {
      final results =
          await LottoRepository.instance.getAll();

      final rounds = results
          .map((item) => item.round)
          .where((round) => round >= 262)
          .toSet()
          .toList();

      rounds.sort(
        (a, b) => b.compareTo(a),
      );

      if (!mounted) return;

      setState(() {
        _rounds = rounds;
        _selectedRound =
            rounds.isNotEmpty ? rounds.first : null;
        _loading = false;
      });

      if (_selectedRound != null) {
        await _loadStores(_selectedRound!);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadStores(int round) async {
    if (mounted) {
      setState(() {
        _loading = true;
        _firstStores = [];
        _secondStores = [];
        _firstPage = 0;
        _secondPage = 0;
      });
    }

    final stores =
        await _api.getStores(round);

    if (!mounted) return;

    setState(() {
      _firstStores = stores
          .where((store) => store.rank == 1)
          .toList();

      _secondStores = stores
          .where((store) => store.rank == 2)
          .toList();

      _loading = false;
    });
  }

  Future<void> _openStoreSearch() async {
    try {
      await launchUrl(
        _storeUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매점'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedRound != null) {
            await _loadStores(
              _selectedRound!,
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOfficialButton(),
            const SizedBox(height: 16),
            _buildRoundSelector(),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildStoreSection(
                title: '🥇 1등 당첨 판매점',
                stores: _firstStores,
                page: _firstPage,
                onPrevious: () {
                  setState(() {
                    _firstPage--;
                  });
                },
                onNext: () {
                  setState(() {
                    _firstPage++;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildStoreSection(
                title: '🥈 2등 당첨 판매점',
                stores: _secondStores,
                page: _secondPage,
                onPrevious: () {
                  setState(() {
                    _secondPage--;
                  });
                },
                onNext: () {
                  setState(() {
                    _secondPage++;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '복권 판매점 찾기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '동행복권 공식 판매점 찾기에서 '
              '지역과 위치를 기준으로 판매점을 찾을 수 있습니다.',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openStoreSearch,
                icon: const Icon(
                  Icons.open_in_new,
                ),
                label: const Text(
                  '동행복권 공식 판매점 찾기',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '당첨 회차 선택',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedRound,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.calendar_month,
                ),
              ),
              items: _rounds.map(
                (round) {
                  return DropdownMenuItem<int>(
                    value: round,
                    child: Text('$round회'),
                  );
                },
              ).toList(),
              onChanged: (round) {
                if (round == null) return;

                setState(() {
                  _selectedRound = round;
                });

                _loadStores(round);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreSection({
    required String title,
    required List<WinningStore> stores,
    required int page,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    final totalPages =
        (stores.length / _pageSize).ceil();

    final start = page * _pageSize;

    final end =
        (start + _pageSize > stores.length)
            ? stores.length
            : start + _pageSize;

    final pageStores =
        start < stores.length
            ? stores.sublist(start, end)
            : <WinningStore>[];

    final hasPrevious = page > 0;
    final hasNext = page + 1 < totalPages;

    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          if (stores.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: Text(
                  '아직 이 회차의 당첨 판매점 정보가 '
                  '업데이트되지 않았습니다.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            ...pageStores.map(
              _buildStoreRow,
            ),
            const SizedBox(height: 8),
            _buildPagination(
              page: page,
              totalPages: totalPages,
              hasPrevious: hasPrevious,
              hasNext: hasNext,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination({
    required int page,
    required int totalPages,
    required bool hasPrevious,
    required bool hasNext,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              hasPrevious ? onPrevious : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
        ),
        Text(
          '${page + 1} / $totalPages',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed:
              hasNext ? onNext : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreRow(
    WinningStore store,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            store.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            store.address.isEmpty
                ? '주소 정보 없음'
                : store.address,
          ),
          if (store.method.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '구매 방식: ${store.method}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}