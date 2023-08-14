import 'dart:async';

import 'package:event_ads/event_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHandler extends AdHandler {
  final String rewardedId;
  final String interstitialId;
  late final adRequest = const AdRequest(nonPersonalizedAds: true);
  final Map<String, Completer> map = {};

  AdMobHandler({
    required this.interstitialId,
    required this.rewardedId,
  });

  bool get supported {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  @override
  FutureOr<void> showAd() {
    if (!supported) {
      throw UnimplementedError();
    }
    return InterstitialAd.load(
      adUnitId: interstitialId,
      request: adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          // Who cares?
        },
      ),
    );
  }

  @override
  FutureOr<RewardResult> showRewardedAd(String id) {
    if (!supported) {
      throw UnimplementedError();
    }
    late final completer = Completer<RewardResult>();
    RewardedAd.load(
      adUnitId: rewardedId,
      request: adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show(
              onUserEarnedReward: (ad, item) =>
                  completer.complete(RewardResult.earned));
        },
        onAdFailedToLoad: (adError) => completer.complete(RewardResult.noLoad),
      ),
    );

    return completer.future;
  }

  @override
  bool get supportsAds => supported;

  @override
  Future<void> initialize() => MobileAds.instance.initialize();
}
