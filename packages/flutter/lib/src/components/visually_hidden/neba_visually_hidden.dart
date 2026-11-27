/// `NebaVisuallyHidden`, content a screen reader reads and the screen does not
/// show.
library;

import 'package:flutter/widgets.dart';

/// Content that is in the semantics tree and not on the screen: the words a
/// control needs a name from when what a sighted reader sees is a glyph, a
/// number or a colour.
///
/// While hidden the child takes no room, paints nothing and takes no pointer,
/// and a screen reader still reads it where it was written, focuses it and
/// acts on it. [visible] takes the hiding off, which is what a skip link
/// needs: hidden until the focus reaches it, then a real control the reader
/// can see.
///
/// ```dart
/// Row(children: <Widget>[
///   const ExcludeSemantics(child: Text('7')),
///   const NebaVisuallyHidden(child: Text('7 unread messages')),
/// ])
/// ```
class NebaVisuallyHidden extends StatelessWidget {
  /// [child], read by a screen reader and not drawn.
  const NebaVisuallyHidden({required this.child, this.visible = false, super.key});

  /// What a screen reader reads.
  final Widget child;

  /// Draws the child like anything else.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return child;
    }

    // Laid out at its own size from a box of none and transparent. A pointer
    // never reaches it, since a hit test stops at the empty box around it,
    // and it stays in the semantics tree with its actions: hiding it any
    // other way takes it off the tree along with the screen.
    return SizedBox.shrink(
      child: OverflowBox(
        alignment: AlignmentDirectional.topStart,
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Opacity(opacity: 0, alwaysIncludeSemantics: true, child: child),
      ),
    );
  }
}
