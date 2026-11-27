import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

List<Widget> _fields() {
  return const <Widget>[
    NebaTextField(
      label: Text('Email'),
      placeholder: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
    ),
    NebaTextField(label: Text('Password'), obscureText: true),
    NebaTextField(label: Text('Team'), description: Text('You can change it later.')),
  ];
}

class FormSpacing extends StatelessWidget {
  const FormSpacing({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.sm.width;
    final NebaGridSpan half = NebaGridSpan.columns(wide ? 6 : 12);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: NebaGridContainer(
        spacing: 8,
        padded: false,
        alignItems: NebaAlignItems.start,
        children: <Widget>[
          // The gap `size` picks: 12 at md.
          NebaGrid(
            span: half,
            child: NebaForm(semanticLabel: 'Default spacing', children: _fields()),
          ),
          // An exact gap: 7 is 28.
          NebaGrid(
            span: half,
            child: NebaForm(semanticLabel: 'Spacing 7', spacing: 7, children: _fields()),
          ),
        ],
      ),
    );
  }
}
