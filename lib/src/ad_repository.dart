import 'dart:async';

import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:uuid/uuid.dart';

typedef RewardedAdCallback = void Function(RewardResult);

enum RewardResult { earned, dismissed, noLoad }

class RewardResultWithId {
  final String id;
  final RewardResult result;

  RewardResultWithId(this.id, this.result);
}

abstract class AdHandler {
  FutureOr<void> showAd();
  FutureOr<RewardResult> showRewardedAd(String id);
  bool get supportsAds;
}

class AdRepository extends Repository {
  final AdHandler adHandler;
  final _showRewardedAdResultStreamController =
      StreamController<RewardResultWithId>.broadcast();

  bool get supportsAds => adHandler.supportsAds;

  AdRepository({required this.adHandler});
  Stream<RewardResultWithId> get showRewardedAdResultStream =>
      _showRewardedAdResultStreamController.stream;

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [
        channel.addEventListener<void>(
            AdEvent.showAd.event, (p0, p1) => adHandler.showAd()),
        channel.addEventListener<String>(
            AdEvent.showRewardedAd.event, (p0, p1) => showRewardedAd(p1)),
        channel.addEventListener<RewardedAdCallback>(
            AdEvent.showRewardedAdWithCallback.event,
            (p0, p1) => showRewardedAdWithCallback(p1)),
      ];

  void showRewardedAd(String id) async {
    final adResult = await adHandler.showRewardedAd(id);
    _showRewardedAdResultStreamController.add(RewardResultWithId(id, adResult));
  }

  void showRewardedAdWithCallback(RewardedAdCallback callback) {
    late final StreamSubscription subscription;
    final id = const Uuid().v4();

    subscription = showRewardedAdResultStream.listen((event) {
      if (event.id != id) {
        return;
      }

      callback(event.result);
      subscription.cancel();
    });

    showRewardedAd(id);
  }
}
