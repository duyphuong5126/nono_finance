import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ad_const.dart';

class AdService {
  static String get bannerAdId {
    if (Platform.isAndroid) {
      return _androidBannerAdId;
    } else if (Platform.isIOS) {
      return _iOSBannerAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

const String _androidBannerAdId =
    kReleaseMode ? androidBannerAdId : androidTestBannerAdId;

const String _iOSBannerAdId = kReleaseMode ? iOSBannerAdId : iOSTestBannerAdId;
