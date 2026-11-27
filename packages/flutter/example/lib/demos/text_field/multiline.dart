import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldMultiline extends StatelessWidget {
  const TextFieldMultiline({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 4,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          NebaGrid(
            span: half,
            child: const NebaTextField(
              multiline: true,
              rows: 1,
              label: Text('rows 1'),
              placeholder: 'Same height as a single line',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              multiline: true,
              rows: 4,
              label: Text('rows 4'),
              description: Text('Grows past four lines as you type.'),
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              multiline: true,
              rows: 3,
              variant: NebaVariant.solid,
              label: Text('solid'),
              initialValue: 'Two lines of\nexisting content',
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
