import 'package:flutter/material.dart';

import '../utils/lotto_colors.dart';

class LottoBall extends StatelessWidget {
  final int number;
  final double size;

  const LottoBall({
    super.key,
    required this.number,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LottoColors.ballColor(number),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: LottoColors.ballTextColor(number),
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}