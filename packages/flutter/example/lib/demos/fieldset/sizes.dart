import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

const List<NebaSize> _sizes = <NebaSize>[NebaSize.sm, NebaSize.md, NebaSize.lg];

class FieldsetSizes extends StatelessWidget {
  const FieldsetSizes({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: NebaGridContainer(
        spacing: 6,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          for (final NebaSize size in _sizes)
            NebaGrid(
              span: NebaGridSpan.columns(wide ? 4 : 12),
              child: NebaFieldset(
                size: size,
                legend: Text(size.name),
                description: const Text('Legend and gap.'),
                children: <Widget>[
                  NebaTextField(size: size, label: const Text('Street')),
                  NebaTextField(size: size, label: const Text('City')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
