import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PanesOrientation extends StatelessWidget {
  const PanesOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.lg.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return NebaGridContainer(
      spacing: 4,
      padded: false,
      children: <Widget>[
        NebaGrid(
          span: half,
          child: const SizedBox(
            height: 160,
            child: NebaPanes(
              children: <NebaPane>[
                NebaPane(child: _Label('horizontal, one')),
                NebaPane(child: _Label('two')),
              ],
            ),
          ),
        ),
        NebaGrid(
          span: half,
          child: const SizedBox(
            height: 160,
            child: NebaPanes(
              orientation: NebaOrientation.vertical,
              children: <NebaPane>[
                NebaPane(child: _Label('vertical, one')),
                NebaPane(child: _Label('two')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: NebaTypography(text, color: NebaColor.secondary),
    );
  }
}
