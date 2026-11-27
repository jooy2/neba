import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class DividerLabels extends StatelessWidget {
  const DividerLabels({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: const NebaFlex(
        direction: NebaOrientation.vertical,
        spacing: 6,
        children: <Widget>[
          NebaDivider(textAlign: NebaAlign.start, child: Text('Recent')),
          NebaDivider(child: Text('Older')),
          NebaDivider(textAlign: NebaAlign.end, child: Text('Archived')),
        ],
      ),
    );
  }
}
