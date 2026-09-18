class WinningStore {
  final int round;
  final int rank;
  final String name;
  final String address;
  final String method;

  const WinningStore({
    required this.round,
    required this.rank,
    required this.name,
    required this.address,
    required this.method,
  });

  factory WinningStore.fromJson(Map<String, dynamic> json) {
    return WinningStore(
      round: _intValue(
        json['round'] ?? json['srchLtEpsd'],
      ),
      rank: _intValue(
        json['rank'] ?? json['srchWnShpRnk'],
      ),
      name: _stringValue(
        json['name'] ??
            json['storeName'] ??
            json['shpNm'],
      ),
      address: _stringValue(
        json['address'] ??
            json['storeAddress'] ??
            json['shpAddr'],
      ),
      method: _stringValue(
        json['method'] ??
            json['buyMethod'] ??
            json['atmtYn'],
      ),
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}