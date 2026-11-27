import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShowRange extends StatelessWidget {
  const ShowRange({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: const NebaFlex(
        wrap: true,
        spacing: 2,
        children: <Widget>[
          NebaShow(
            below: NebaBreakpoint.sm,
            child: NebaChip(color: NebaColor.secondary, child: Text('xs — under 640 pixels')),
          ),
          NebaShow(
            above: NebaBreakpoint.sm,
            below: NebaBreakpoint.lg,
            child: NebaChip(child: Text('sm and md — 640 to 1024 pixels')),
          ),
          NebaShow(
            above: NebaBreakpoint.lg,
            child: NebaChip(color: NebaColor.success, child: Text('lg and up — 1024 and over')),
          ),
        ],
      ),
    );
  }
}
