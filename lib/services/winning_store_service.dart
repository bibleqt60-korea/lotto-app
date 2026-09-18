import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/winning_store.dart';

class WinningStoreService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/'
      'bibleqt60-korea/lotto-data/main/data/stores/';

  Future<List<WinningStore>> getStores(
    int round,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$round.json'),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final body = response.body.trim();

      if (body.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final first = _parseList(
        decoded['first'],
        round,
        1,
      );

      final second = _parseList(
        decoded['second'],
        round,
        2,
      );

      return [
        ...first,
        ...second,
      ];
    } catch (_) {
      return [];
    }
  }

  List<WinningStore> _parseList(
    dynamic value,
    int round,
    int rank,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) {
            final json =
                Map<String, dynamic>.from(item);

            json['round'] = round;
            json['rank'] = rank;

            return WinningStore.fromJson(json);
          },
        )
        .where(
          (store) => store.name.isNotEmpty,
        )
        .toList();
  }

  Future<List<WinningStore>> getFirstStores(
    int round,
  ) async {
    final stores = await getStores(round);

    return stores
        .where((store) => store.rank == 1)
        .toList();
  }

  Future<List<WinningStore>> getSecondStores(
    int round,
  ) async {
    final stores = await getStores(round);

    return stores
        .where((store) => store.rank == 2)
        .toList();
  }
}