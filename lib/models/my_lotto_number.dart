class MyLottoNumber {
  final String id;
  final List<int> numbers;
  final DateTime createdAt;
  final String memo;

  const MyLottoNumber({
    required this.id,
    required this.numbers,
    required this.createdAt,
    this.memo = '',
  });

  factory MyLottoNumber.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawNumbers = json['numbers'];

    final numbers = rawNumbers is List
        ? rawNumbers
            .map((item) => _intValue(item))
            .where(
              (number) => number >= 1 && number <= 45,
            )
            .toList()
        : <int>[];

    return MyLottoNumber(
      id: json['id']?.toString() ?? '',
      numbers: numbers,
      createdAt: DateTime.tryParse(
            json['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      memo: json['memo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numbers': numbers,
      'createdAt': createdAt.toIso8601String(),
      'memo': memo,
    };
  }

  MyLottoNumber copyWith({
    String? id,
    List<int>? numbers,
    DateTime? createdAt,
    String? memo,
  }) {
    return MyLottoNumber(
      id: id ?? this.id,
      numbers: numbers ?? this.numbers,
      createdAt: createdAt ?? this.createdAt,
      memo: memo ?? this.memo,
    );
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}