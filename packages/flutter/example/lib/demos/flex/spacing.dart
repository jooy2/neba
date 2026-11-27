import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<String> _tags = <String>[
  'production',
  'staging',
  'preview',
  'canary',
  'edge',
  'legacy',
  'archived',
];

class FlexSpacing extends StatelessWidget {
  const FlexSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    // A tighter gutter on a phone, read off the window as a breakpoint is.
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: NebaFlex(
        wrap: true,
        spacing: wide ? 3 : 1,
        children: <Widget>[for (final String tag in _tags) NebaChip(child: Text(tag))],
      ),
    );
  }
}
