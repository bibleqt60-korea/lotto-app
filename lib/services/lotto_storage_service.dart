import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lotto_result.dart';

class LottoStorageService {
  LottoStorageService._();

  static final LottoStorageService instance =
      LottoStorageService._();

  static const String _resultsKey = 'lotto_results';

  Future<List<LottoResult>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resultsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      final results = decoded
          .whereType<Map>()
          .map(
            (item) => LottoResult.fromStorageJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      results.sort(
        (a, b) => a.round.compareTo(b.round),
      );

      return results;
    } catch (_) {
      return [];
    }
  }

  Future<LottoResult?> getRound(int round) async {
    final results = await loadAll();

    for (final result in results) {
      if (result.round == round) {
        return result;
      }
    }

    return null;
  }

  Future<LottoResult?> getLatest() async {
    final results = await loadAll();

    if (results.isEmpty) {
      return null;
    }

    return results.last;
  }

  Future<void> saveRound(LottoResult result) async {
    final results = await loadAll();

    final index = results.indexWhere(
      (item) => item.round == result.round,
    );

    if (index >= 0) {
      results[index] = result;
    } else {
      results.add(result);
    }

    results.sort(
      (a, b) => a.round.compareTo(b.round),
    );

    await saveAll(results);
  }

  Future<void> saveAll(List<LottoResult> results) async {
    final prefs = await SharedPreferences.getInstance();

    final sorted = [...results]
      ..sort(
        (a, b) => a.round.compareTo(b.round),
      );

    final encoded = jsonEncode(
      sorted.map((result) => result.toJson()).toList(),
    );

    await prefs.setString(
      _resultsKey,
      encoded,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_resultsKey);
  }
}