/// The gallery's line to the documentation page around it.
///
/// On the web the gallery is the renderer behind every Flutter preview, inside
/// an iframe the page sizes and themes. Everywhere else there is no page, and
/// the bridge does nothing.
library;

export 'package:neba_example/host_bridge_stub.dart'
    if (dart.library.js_interop) 'package:neba_example/host_bridge_web.dart';
