import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldStates extends StatelessWidget {
  const TextFieldStates({super.key});

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
              label: Text('Normal'),
              initialValue: 'Value',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('Read-only'),
              initialValue: 'Value',
              readOnly: true,
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('Disabled'),
              initialValue: 'Value',
              disabled: true,
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('Invalid'),
              initialValue: 'not-an-email',
              error: Text('Enter a valid address.'),
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
