class LottoResult {
  final int round;
  final String drawDate;
  final List<int> numbers;
  final int bonusNumber;

  final int firstWinnerCount;
  final int secondWinnerCount;
  final int thirdWinnerCount;
  final int fourthWinnerCount;
  final int fifthWinnerCount;

  final int firstPrize;
  final int secondPrize;
  final int thirdPrize;
  final int fourthPrize;
  final int fifthPrize;

  const LottoResult({
    required this.round,
    required this.drawDate,
    required this.numbers,
    required this.bonusNumber,
    this.firstWinnerCount = 0,
    this.secondWinnerCount = 0,
    this.thirdWinnerCount = 0,
    this.fourthWinnerCount = 0,
    this.fifthWinnerCount = 0,
    this.firstPrize = 0,
    this.secondPrize = 0,
    this.thirdPrize = 0,
    this.fourthPrize = 0,
    this.fifthPrize = 0,
  });

  factory LottoResult.fromApiJson(
    Map<String, dynamic> json,
  ) {
    return LottoResult(
      round: _intValue(json['drwtNo']),
      drawDate: json['drwNoDate']?.toString() ?? '',
      numbers: [
        _intValue(json['drwtNo1']),
        _intValue(json['drwtNo2']),
        _intValue(json['drwtNo3']),
        _intValue(json['drwtNo4']),
        _intValue(json['drwtNo5']),
        _intValue(json['drwtNo6']),
      ],
      bonusNumber: _intValue(json['bnusNo']),
      firstWinnerCount:
          _intValue(json['firstPrzwnerCo']),
      secondWinnerCount:
          _intValue(json['secondPrzwnerCo']),
      thirdWinnerCount:
          _intValue(json['thirdPrzwnerCo']),
      fourthWinnerCount:
          _intValue(json['fourthPrzwnerCo']),
      fifthWinnerCount:
          _intValue(json['fifthPrzwnerCo']),
      firstPrize:
          _intValue(json['firstWinamnt']),
      secondPrize:
          _intValue(json['secondWinamnt']),
      thirdPrize:
          _intValue(json['thirdWinamnt']),
      fourthPrize:
          _intValue(json['fourthWinamnt']),
      fifthPrize:
          _intValue(json['fifthWinamnt']),
    );
  }

  factory LottoResult.fromStorageJson(
    Map<String, dynamic> json,
  ) {
    final rawNumbers = json['numbers'];

    final numbers = rawNumbers is List
        ? rawNumbers
            .map(_intValue)
            .where((number) => number >= 1)
            .toList()
        : <int>[];

    return LottoResult(
      round: _intValue(json['round']),
      drawDate:
          json['drawDate']?.toString() ?? '',
      numbers: numbers,
      bonusNumber:
          _intValue(json['bonusNumber']),
      firstWinnerCount:
          _intValue(json['firstWinnerCount']),
      secondWinnerCount:
          _intValue(json['secondWinnerCount']),
      thirdWinnerCount:
          _intValue(json['thirdWinnerCount']),
      fourthWinnerCount:
          _intValue(json['fourthWinnerCount']),
      fifthWinnerCount:
          _intValue(json['fifthWinnerCount']),
      firstPrize:
          _intValue(json['firstPrize']),
      secondPrize:
          _intValue(json['secondPrize']),
      thirdPrize:
          _intValue(json['thirdPrize']),
      fourthPrize:
          _intValue(json['fourthPrize']),
      fifthPrize:
          _intValue(json['fifthPrize']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'drawDate': drawDate,
      'numbers': numbers,
      'bonusNumber': bonusNumber,
      'firstWinnerCount': firstWinnerCount,
      'secondWinnerCount': secondWinnerCount,
      'thirdWinnerCount': thirdWinnerCount,
      'fourthWinnerCount': fourthWinnerCount,
      'fifthWinnerCount': fifthWinnerCount,
      'firstPrize': firstPrize,
      'secondPrize': secondPrize,
      'thirdPrize': thirdPrize,
      'fourthPrize': fourthPrize,
      'fifthPrize': fifthPrize,
    };
  }

  LottoResult copyWith({
    int? round,
    String? drawDate,
    List<int>? numbers,
    int? bonusNumber,
    int? firstWinnerCount,
    int? secondWinnerCount,
    int? thirdWinnerCount,
    int? fourthWinnerCount,
    int? fifthWinnerCount,
    int? firstPrize,
    int? secondPrize,
    int? thirdPrize,
    int? fourthPrize,
    int? fifthPrize,
  }) {
    return LottoResult(
      round: round ?? this.round,
      drawDate: drawDate ?? this.drawDate,
      numbers: numbers ?? this.numbers,
      bonusNumber:
          bonusNumber ?? this.bonusNumber,
      firstWinnerCount:
          firstWinnerCount ?? this.firstWinnerCount,
      secondWinnerCount:
          secondWinnerCount ?? this.secondWinnerCount,
      thirdWinnerCount:
          thirdWinnerCount ?? this.thirdWinnerCount,
      fourthWinnerCount:
          fourthWinnerCount ?? this.fourthWinnerCount,
      fifthWinnerCount:
          fifthWinnerCount ?? this.fifthWinnerCount,
      firstPrize:
          firstPrize ?? this.firstPrize,
      secondPrize:
          secondPrize ?? this.secondPrize,
      thirdPrize:
          thirdPrize ?? this.thirdPrize,
      fourthPrize:
          fourthPrize ?? this.fourthPrize,
      fifthPrize:
          fifthPrize ?? this.fifthPrize,
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