import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ShowPair extends StatelessWidget {
  const ShowPair({super.key});

  @override
  Widget build(BuildContext context) {
    void press() {}

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NebaShow(
              below: NebaBreakpoint.sm,
              child: NebaButton(onPressed: press, fullWidth: true, child: const Text('Actions')),
            ),
            NebaShow(
              above: NebaBreakpoint.sm,
              child: NebaButtonGroup(
                children: <Widget>[
                  NebaButton(onPressed: press, child: const Text('Duplicate')),
                  NebaButton(onPressed: press, child: const Text('Archive')),
                  NebaButton(onPressed: press, child: const Text('Export')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
