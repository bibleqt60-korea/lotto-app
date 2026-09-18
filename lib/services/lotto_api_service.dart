import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lotto_result.dart';

class LottoApiService {
  LottoApiService();

  static const String _baseUrl =
      'https://raw.githubusercontent.com/'
      'bibleqt60-korea/lotto-data/main/data/';

  static const String _latestUrl =
      '${_baseUrl}latest.json';

  static const String _dataUrl =
      '${_baseUrl}lotto.json';

  Future<int> getLatestRound() async {
    final response = await http.get(
      Uri.parse(_latestUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        '최신 로또 정보 확인 실패: '
        '${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    return int.tryParse(
          '${data['latestRound']}',
        ) ??
        0;
  }

  Future<List<LottoResult>> getAll() async {
    final response = await http.get(
      Uri.parse(_dataUrl),
    );

    if (response.statusCode != 200) {
      throw Exception(
        '로또 데이터 다운로드 실패: '
        '${response.statusCode}',
      );
    }

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    final rawResults = data['results'];

    if (rawResults is! List) {
      return [];
    }

    return rawResults
        .whereType<Map>()
        .map(
          (item) => LottoResult.fromStorageJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (item) =>
              item.round > 0 &&
              item.numbers.length == 6,
        )
        .toList()
      ..sort(
        (a, b) => a.round.compareTo(b.round),
      );
  }

  Future<LottoResult?> getRound(
    int round,
  ) async {
    final results = await getAll();

    for (final result in results) {
      if (result.round == round) {
        return result;
      }
    }

    return null;
  }
}