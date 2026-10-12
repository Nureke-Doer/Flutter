import 'dart:async';

import 'package:flutter/foundation.dart';

/// Превращает поток в `Listenable`, чтобы GoRouter заново вызывал
/// `redirect` при каждом событии (например, при входе или выходе).
class StreamRefreshListenable extends ChangeNotifier {
  StreamRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
