import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';

/// The channel both ends agree on. `docs/.vitepress/theme/components/Demo.vue`
/// uses the same name.
const String _channel = 'neba-demo';

/// The bridge on the web, written against `dart:js_interop` alone so the
/// gallery needs no package for the two messages it sends and takes.
class HostBridge {
  /// A bridge onto the page this gallery is embedded in.
  const HostBridge();

  String get _origin {
    final JSObject location = globalContext['location']! as JSObject;

    return (location['origin']! as JSString).toDart;
  }

  /// Tells the page how tall the preview is, so it can size the frame to it.
  void reportHeight(double height) {
    final JSObject? parent = globalContext['parent'] as JSObject?;

    if (parent == null || parent.strictEquals(globalContext).toDart) {
      return;
    }

    parent.callMethod<JSAny?>(
      'postMessage'.toJS,
      <String, Object>{'channel': _channel, 'type': 'size', 'height': height}.jsify(),
      _origin.toJS,
    );
  }

  /// Calls [handler] whenever the page flips this preview's theme.
  ///
  /// Only a message from the page's own origin is read: the gallery is served
  /// out of the documentation site, so anything from elsewhere is not the page.
  void onTheme(ValueChanged<Brightness> handler) {
    void listener(JSObject event) {
      final JSString? origin = event['origin'] as JSString?;

      if (origin == null || origin.toDart != _origin) {
        return;
      }

      final Object? data = event['data'].dartify();

      if (data is! Map || data['channel'] != _channel || data['type'] != 'theme') {
        return;
      }

      handler(data['theme'] == 'dark' ? Brightness.dark : Brightness.light);
    }

    globalContext.callMethod<JSAny?>('addEventListener'.toJS, 'message'.toJS, listener.toJS);
  }
}
