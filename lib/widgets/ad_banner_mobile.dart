import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerPlatform extends StatefulWidget {
  const AdBannerPlatform({super.key});

  @override
  State<AdBannerPlatform> createState() =>
      _AdBannerPlatformState();
}

class _AdBannerPlatformState
    extends State<AdBannerPlatform> {
  BannerAd? _banner;
  bool _loaded = false;

  String get _adUnitId {
    if (Platform.isIOS) {
      return 'ca-app-pub-5663533922736885/8496928885';
    }

    return 'ca-app-pub-5663533922736885/9454787331';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_banner == null) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    final width =
        MediaQuery.of(context).size.width.truncate();

    final size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      width,
    );

    if (size == null) return;

    final banner = BannerAd(
      adUnitId: _adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;

          setState(() {
            _banner = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: _banner!.size.height.toDouble(),
      child: AdWidget(
        ad: _banner!,
      ),
    );
  }
}