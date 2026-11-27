/// A region a screen reader reads out when what it says changes: the React
/// package's `role="alert"` and `role="status"`.
///
/// `alert` interrupts whatever a screen reader is in the middle of saying and
/// `status` waits for a pause. Flutter has both roles, but only the web reads
/// them: there [SemanticsRole.alert] and [SemanticsRole.status] become the
/// same ARIA roles the React package writes. Android and iOS have no such
/// roles and announce a live region instead, which has one way of speaking,
/// so there both are a live region. A node cannot be both, which is why the
/// platform decides rather than both being written.
///
/// The library talking to itself: nothing here is exported.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// [child] as one semantics node in [role], read out as it changes when the
/// role is [SemanticsRole.alert] or [SemanticsRole.status].
///
/// What is inside merges into the node, so its label is the whole of what is
/// read. Any other role is written as it is, and [SemanticsRole.none] is a
/// region that is not live.
class NebaLiveRegion extends StatelessWidget {
  /// A region in [role] around [child].
  const NebaLiveRegion({required this.role, required this.child, this.web = kIsWeb, super.key});

  /// What the region is.
  final SemanticsRole role;

  /// Whether the roles reach a screen reader, which they do on the web alone.
  /// For a test of the other platform.
  final bool web;

  /// What is read out.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool live = role == SemanticsRole.alert || role == SemanticsRole.status;

    if (live && !web) {
      return Semantics(container: true, liveRegion: true, child: child);
    }

    return Semantics(container: true, role: role, child: child);
  }
}
