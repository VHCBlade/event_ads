import 'package:event_ads/event_ads.dart';
import 'package:event_bloc/event_bloc_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoadingAdWatcher extends StatefulWidget {
  const LoadingAdWatcher({super.key, required this.child});
  final Widget child;

  @override
  State<LoadingAdWatcher> createState() => _LoadingAdWatcherState();
}

class _LoadingAdWatcherState extends State<LoadingAdWatcher> {
  late final BlocEventListener<dynamic> listener;

  @override
  void initState() {
    super.initState();
    listener = context.eventChannel.eventBus.addEventListener(
      AdEvent.loadingAd.event,
      (event, value) => Fluttertoast.showToast(
        msg: 'Ad is loading...',
        toastLength: Toast.LENGTH_LONG,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    listener.unsubscribe();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
