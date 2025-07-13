import 'dart:async';

class ReloadService {
  static bool _homeNeedsReload = false;
  static final StreamController<bool> _reloadController =
      StreamController<bool>.broadcast();

  static void setHomeNeedsReload() {
    _homeNeedsReload = true;
    _reloadController.add(true);
  }

  static bool getAndClearHomeNeedsReload() {
    final needsReload = _homeNeedsReload;
    _homeNeedsReload = false;
    return needsReload;
  }

  static Stream<bool> get reloadStream => _reloadController.stream;

  static void dispose() {
    _reloadController.close();
  }
}
