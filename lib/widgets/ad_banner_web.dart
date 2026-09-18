import 'package:flutter/material.dart';

class AdBannerPlatform extends StatelessWidget {
  const AdBannerPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: const Text(
        'WEB 광고 영역',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }
}