import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class FlexDirection extends StatelessWidget {
  const FlexDirection({super.key});

  @override
  Widget build(BuildContext context) {
    // The commonest responsive form there is: a field and its action side by
    // side once there is room, and stacked before there is, read off the
    // window as a breakpoint is.
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    const Widget field = NebaTextField(
      label: Text('Work email'),
      placeholder: 'you@company.com',
      fullWidth: true,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: NebaFlex(
        direction: wide ? NebaOrientation.horizontal : NebaOrientation.vertical,
        spacing: 2,
        alignItems: wide ? NebaAlignItems.end : NebaAlignItems.stretch,
        children: <Widget>[
          if (wide) const Expanded(child: field) else field,
          NebaButton(onPressed: () {}, child: const Text('Request access')),
        ],
      ),
    );
  }
}
