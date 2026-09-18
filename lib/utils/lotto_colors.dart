import 'package:flutter/material.dart';

class LottoColors {
  static Color ballColor(int number) {
    if (number <= 10) {
      return Colors.amber;
    }

    if (number <= 20) {
      return Colors.blue;
    }

    if (number <= 30) {
      return Colors.red;
    }

    if (number <= 40) {
      return Colors.grey.shade700;
    }

    return Colors.green;
  }

  static Color ballTextColor(int number) {
    if (number >= 11 && number <= 20) {
      return Colors.white;
    }

    if (number >= 21 && number <= 30) {
      return Colors.white;
    }

    if (number >= 31 && number <= 40) {
      return Colors.white;
    }

    if (number >= 41 && number <= 45) {
      return Colors.white;
    }

    return Colors.black;
  }
}