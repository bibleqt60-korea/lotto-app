import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class AdBannerPlatform extends StatefulWidget {
  const AdBannerPlatform({super.key});

  @override
  State<AdBannerPlatform> createState() =>
      _AdBannerPlatformState();
}

class _AdBannerPlatformState
    extends State<AdBannerPlatform> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();

    _viewType =
        'adsense-${DateTime.now().microsecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final container = web.HTMLDivElement();

        container.style.width = '100%';
        container.style.height = '90px';

        final ad = web.document.createElement('ins');

        ad.className = 'adsbygoogle';

        ad.setAttribute(
          'style',
          'display:block;width:100%;height:90px;',
        );

        ad.setAttribute(
          'data-ad-client',
          'ca-pub-5663533922736885',
        );

        ad.setAttribute(
          'data-ad-slot',
          '2364734996',
        );

        ad.setAttribute(
          'data-ad-format',
          'auto',
        );

        ad.setAttribute(
          'data-full-width-responsive',
          'true',
        );

        container.append(ad);

        final script = web.HTMLScriptElement();

        script.text =
            '(adsbygoogle = window.adsbygoogle || []).push({});';

        container.append(script);

        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: HtmlElementView(
        viewType: _viewType,
      ),
    );
  }
}