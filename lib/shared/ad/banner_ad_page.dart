import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

class BannerAdPage extends StatefulWidget {
  const BannerAdPage({
    super.key,
    required this.body,
    required this.onBannerAdFailed,
  });

  final Widget body;
  final Function(LoadAdError) onBannerAdFailed;

  @override
  State<BannerAdPage> createState() => _BannerAdPageState();
}

class _BannerAdPageState extends State<BannerAdPage> {
  late BannerAd _bannerAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          log('Ad loaded');
          setState(() {
            _isAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          log('Ad failed to load with error $err');
          setState(() {
            _isAdReady = false;
          });
          widget.onBannerAdFailed(err);
          ad.dispose();
        },
      ),
    );

    if (Platform.isAndroid) {
      _bannerAd.load();
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdReady
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: _bannerAd.size.height.toDouble(),
                ),
                child: widget.body,
              ),
              SizedBox(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ],
          )
        : widget.body;
  }
}
