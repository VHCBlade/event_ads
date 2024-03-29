import 'package:event_bloc/event_bloc.dart';

import 'ad_repository.dart';

enum AdEvent<T> {
  showAd<void>(),
  showRewardedAd<String>(),
  showRewardedAdWithCallback<RewardedAdCallback>(),

  loadingAd<void>(),
  ;

  BlocEventType<T> get event => BlocEventType.fromObject(this);
}
