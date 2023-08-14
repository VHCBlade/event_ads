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
  Future<void> initialize();
  FutureOr<void> showAd();
  FutureOr<RewardResult> showRewardedAd(String id);
  bool get supportsAds;
}

class AdRepository extends Repository {
  final AdHandler adHandler;
  final _showRewardedAdResultStreamController =
      StreamController<RewardResultWithId>.broadcast();

  bool get supportsAds => adHandler.supportsAds;
  bool attemptedToInitialize = false;
  final completer = Completer();

  AdRepository({required this.adHandler});
  Stream<RewardResultWithId> get showRewardedAdResultStream =>
      _showRewardedAdResultStreamController.stream;

  @override
  void initialize(BlocEventChannel channel) async {
    super.initialize(channel);
    if (attemptedToInitialize) {
      return;
    }
    attemptedToInitialize = true;
    await adHandler.initialize();
    completer.complete();
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) => [
        channel.addEventListener<void>(
            AdEvent.showAd.event, (p0, p1) => showAd()),
        channel.addEventListener<String>(
            AdEvent.showRewardedAd.event, (p0, p1) => showRewardedAd(p1)),
        channel.addEventListener<RewardedAdCallback>(
            AdEvent.showRewardedAdWithCallback.event,
            (p0, p1) => showRewardedAdWithCallback(p1)),
      ];

  Future<void> showAd() async {
    final loadingAd = adHandler.showAd();
    channel.eventBus.fireEvent(AdEvent.loadingAd.event, null);

    await loadingAd;
  }

  Future<void> showRewardedAd(String id) async {
    final adResult = adHandler.showRewardedAd(id);
    channel.eventBus.fireEvent(AdEvent.loadingAd.event, null);
    _showRewardedAdResultStreamController
        .add(RewardResultWithId(id, await adResult));
  }

  Future<void> showRewardedAdWithCallback(RewardedAdCallback callback) {
    late final StreamSubscription subscription;
    final id = const Uuid().v4();

    subscription = showRewardedAdResultStream.listen(
      (event) {
        if (event.id != id) {
          return;
        }

        callback(event.result);
        subscription.cancel();
      },
    );

    return showRewardedAd(id);
  }
}
