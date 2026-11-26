import 'package:flutter/widgets.dart';

/// The bridge off the web: there is no page to talk to.
class HostBridge {
  /// A bridge that does nothing.
  const HostBridge();

  /// Does nothing off the web.
  void reportHeight(double height) {}

  /// Does nothing off the web.
  void onTheme(ValueChanged<Brightness> handler) {}
}
