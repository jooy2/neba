import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// `resizable: false` leaves the split as a layout: the bar is still drawn as
/// a rule between the panes, but it is not something to grab.
class PanesFixed extends StatelessWidget {
  const PanesFixed({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      child: NebaPanes(
        resizable: false,
        children: <NebaPane>[
          NebaPane(defaultSize: NebaPaneSize.percent(30), child: _Label('Fixed at 30%')),
          NebaPane(child: _Label('The rest')),
        ],
      ),
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
