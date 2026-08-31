import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:uchinaguchi_jisho/models/word_item.dart';

class DeeplinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  // A controller where [stream] can be listened to more than once.
  final StreamController<WordItem> _wordStreamController =
      StreamController<WordItem>.broadcast();

  // Getter of public stream to be listened to.
  Stream<WordItem> get onWordReceived => _wordStreamController.stream;

  // Uri handling and data translation to WordItem.
  void _handleUri(Uri uri) {
    final word = WordItem.fromDeepLink(uri);
    if (word != null) {
      _wordStreamController.add(word);
    }
  }

  Future<void> init() async {
    // Check if app was launched by link (closed before event).
    final Uri? initialUri = await _appLinks.getInitialLink();
    try {
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      log("Error on Deepling init${e.toString()}");
    }
    // Subscribe for links while the app is in background.
    _sub = _appLinks.uriLinkStream.listen(
      (uriEvent) => _handleUri(uriEvent),
      onError: (e) => log('Error on subs: ${e.toString()}'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _wordStreamController.close();
  }
}
