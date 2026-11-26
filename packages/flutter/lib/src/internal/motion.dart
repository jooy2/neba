/// How long a change takes, in one place.
///
/// Press is instant and release is slow: a colour changes in zero time while a
/// control is pressed and settles over its own duration afterwards. And a
/// reader who asked the platform for less motion gets zero everywhere, as the
/// React package's `prefers-reduced-motion` block sets every duration to 0ms.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/widgets.dart';

/// Whether the platform asked for less motion.
bool nebaReducedMotion(BuildContext context) {
  return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// [duration], or zero when the change is a press or the reader asked for
/// less motion.
Duration nebaDuration(BuildContext context, Duration duration, {bool instant = false}) {
  return instant || nebaReducedMotion(context) ? Duration.zero : duration;
}
