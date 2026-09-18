import 'package:flutter/material.dart';

import 'ad_banner_mobile.dart'
    if (dart.library.html) 'ad_banner_web.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdBannerPlatform();
  }
}