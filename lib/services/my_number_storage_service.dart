import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/my_lotto_number.dart';

class MyNumberStorageService {
  MyNumberStorageService();

  static const String _key =
      'my_lotto_numbers';

  Future<List<MyLottoNumber>> loadAll() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => MyLottoNumber.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(
    MyLottoNumber number,
  ) async {
    final numbers = await loadAll();

    final index = numbers.indexWhere(
      (item) => item.id == number.id,
    );

    if (index >= 0) {
      numbers[index] = number;
    } else {
      numbers.insert(0, number);
    }

    await _saveAll(numbers);
  }

  Future<void> delete(String id) async {
    final numbers = await loadAll();

    numbers.removeWhere(
      (item) => item.id == id,
    );

    await _saveAll(numbers);
  }

  Future<void> clear() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }

  Future<void> _saveAll(
    List<MyLottoNumber> numbers,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      numbers
          .map((number) => number.toJson())
          .toList(),
    );

    await prefs.setString(
      _key,
      encoded,
    );
  }
}