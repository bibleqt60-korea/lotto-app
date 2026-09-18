import 'package:flutter_test/flutter_test.dart';

import 'package:lotto_app/app.dart';

void main() {
  testWidgets(
    '로또 앱이 정상적으로 생성된다',
    (tester) async {
      await tester.pumpWidget(
        const LottoApp(),
      );

      expect(
        find.text('로또 6/45'),
        findsOneWidget,
      );

      expect(
        find.text('홈'),
        findsOneWidget,
      );

      expect(
        find.text('판매점'),
        findsOneWidget,
      );

      expect(
        find.text('통계'),
        findsOneWidget,
      );

      expect(
        find.text('번호생성'),
        findsOneWidget,
      );

      expect(
        find.text('내 번호'),
        findsOneWidget,
      );
    },
  );
}