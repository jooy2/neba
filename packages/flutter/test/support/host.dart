// What every widget test pumps a widget into.
//
// No `MaterialApp` and no `WidgetsApp`: the package imports neither Material
// nor Cupertino, so a test that passes only inside one of them is not testing
// what a consumer gets. A widget needs a direction and a media query, and that
// is all this gives it.

import 'package:flutter/widgets.dart';

/// [child] laid out the way an app would lay it out, with nothing else around
/// it.
///
/// [brightness] is the platform's, which is what a widget follows when no
/// theme pins one. [highContrast] is the accessibility setting the tokens read
/// as a request for less transparency.
Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  bool highContrast = false,
  bool disableAnimations = false,
  TextDirection textDirection = TextDirection.ltr,
  double width = 800,
  double height = 600,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: Size(width, height),
      platformBrightness: brightness,
      highContrast: highContrast,
      disableAnimations: disableAnimations,
    ),
    child: Directionality(
      textDirection: textDirection,
      child: Center(
        child: SizedBox(width: width, height: height, child: child),
      ),
    ),
  );
}
