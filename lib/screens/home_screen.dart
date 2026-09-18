import 'package:flutter/material.dart';

import '../models/lotto_result.dart';
import '../models/winning_store.dart';
import '../services/lotto_repository.dart';
import '../services/update_service.dart';
import '../services/winning_store_api_service.dart';
import '../widgets/lotto_ball.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LottoRepository _lottoRepository =
      LottoRepository.instance;

  final UpdateService _updateService =
      UpdateService();

  final WinningStoreApiService _storeService =
      WinningStoreApiService();

  LottoResult? _latest;

  List<WinningStore> _firstStores = [];
  List<WinningStore> _secondStores = [];

  bool _loading = true;
  bool _refreshing = false;
  bool _storeLoading = false;

  int _firstPage = 0;
  int _secondPage = 0;

  static const int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final latest =
          await _lottoRepository.getLatest();

      if (!mounted) return;

      setState(() {
        _latest = latest;
        _loading = false;
      });

      if (latest != null) {
        _loadWinningStores(latest.round);
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadWinningStores(
    int round,
  ) async {
    if (_storeLoading) return;

    setState(() {
      _storeLoading = true;
      _firstPage = 0;
      _secondPage = 0;
    });

    try {
      final results = await Future.wait([
        _storeService.getFirstStores(round),
        _storeService.getSecondStores(round),
      ]);

      if (!mounted) return;

      setState(() {
        _firstStores = results[0];
        _secondStores = results[1];
        _storeLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _firstStores = [];
        _secondStores = [];
        _storeLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
    });

    try {
      final result =
          await _updateService.update();

      await _loadHome();

      if (!mounted) return;

      if (result.hasNewData) {
        _showMessage(
          '${result.addedCount}회차의 새로운 데이터가 추가되었습니다.',
        );
      } else {
        _showMessage('최신 데이터입니다.');
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage('데이터를 가져오지 못했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  List<WinningStore> _getPage(
    List<WinningStore> stores,
    int page,
  ) {
    final start = page * _pageSize;

    if (start >= stores.length) {
      return [];
    }

    final end =
        (start + _pageSize > stores.length)
            ? stores.length
            : start + _pageSize;

    return stores.sublist(start, end);
  }

  int _pageCount(List<WinningStore> stores) {
    if (stores.isEmpty) return 0;

    return (stores.length + _pageSize - 1) ~/
        _pageSize;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildLatestHeader(),
        const SizedBox(height: 16),
        _buildLatestNumbers(),
        const SizedBox(height: 20),
        _buildWinnerSection(),
        if (_firstStores.isNotEmpty ||
            _secondStores.isNotEmpty ||
            _storeLoading) ...[
          const SizedBox(height: 20),
          _buildWinningStoreSection(),
        ],
      ],
    );
  }

  Widget _buildLatestHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _latest == null
                ? '로또 6/45'
                : '${_latest!.round}회차 · ${_latest!.drawDate}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: _refreshing ? null : _refresh,
          icon: _refreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildLatestNumbers() {
    if (_latest == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                '저장된 로또 데이터가 없습니다.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    _refreshing ? null : _refresh,
                child: const Text('데이터 가져오기'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._latest!.numbers.map(
                  (number) => LottoBall(
                    number: number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  '보너스',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                LottoBall(
                  number: _latest!.bonusNumber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerSection() {
    return ExpansionTile(
      initiallyExpanded: true,
      title: const Text('당첨 정보'),
      children: [
        if (_latest != null) _winnerTable(),
      ],
    );
  }

  Widget _winnerTable() {
    return Column(
      children: [
        _winnerRow(
          '1등',
          _latest!.firstWinnerCount,
          _latest!.firstPrize,
        ),
        _winnerRow(
          '2등',
          _latest!.secondWinnerCount,
          _latest!.secondPrize,
        ),
        _winnerRow(
          '3등',
          _latest!.thirdWinnerCount,
          _latest!.thirdPrize,
        ),
        _winnerRow(
          '4등',
          _latest!.fourthWinnerCount,
          _latest!.fourthPrize,
        ),
        _winnerRow(
          '5등',
          _latest!.fifthWinnerCount,
          _latest!.fifthPrize,
        ),
      ],
    );
  }

  Widget _winnerRow(
    String rank,
    int count,
    int prize,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(
        rank,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          '${_formatMoney(count)}게임',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: Text(
        '${_formatMoney(prize)}원',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWinningStoreSection() {
    return Column(
      children: [
        if (_storeLoading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        if (!_storeLoading &&
            _firstStores.isNotEmpty)
          _buildStoreGroup(
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
        if (!_storeLoading &&
            _firstStores.isNotEmpty &&
            _secondStores.isNotEmpty)
          const SizedBox(height: 10),
        if (!_storeLoading &&
            _secondStores.isNotEmpty)
          _buildStoreGroup(
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
    );
  }

  Widget _buildStoreGroup({
    required String title,
    required List<WinningStore> stores,
    required int page,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    final pageItems = _getPage(stores, page);
    final pageCount = _pageCount(stores);

    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${stores.length}곳 · 5개씩 보기',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              12,
            ),
            child: Column(
              children: [
                ...pageItems.map(_buildStoreRow),
                if (pageCount > 1)
                  _buildStorePagination(
                    page: page,
                    pageCount: pageCount,
                    onPrevious: onPrevious,
                    onNext: onNext,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorePagination({
    required int page,
    required int pageCount,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: page > 0 ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${page + 1} / $pageCount',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed:
              page < pageCount - 1 ? onNext : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildStoreRow(
    WinningStore store,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(
        Icons.storefront_outlined,
      ),
      title: Text(
        store.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (store.address.isNotEmpty)
            Text(store.address),
          if (store.method.isNotEmpty)
            Text(
              '구매 방식: ${store.method}',
            ),
        ],
      ),
    );
  }

  String _formatMoney(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}