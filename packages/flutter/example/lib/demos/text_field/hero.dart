import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldHero extends StatelessWidget {
  const TextFieldHero({super.key});

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
              label: Text('Email'),
              placeholder: 'jane@example.com',
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('Display name'),
              initialValue: 'Jane',
              description: Text('Shown on your public profile.'),
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('Password'),
              obscureText: true,
              initialValue: 'secret',
              error: Text('Must be at least 8 characters.'),
              fullWidth: true,
            ),
          ),
          NebaGrid(
            span: half,
            child: const NebaTextField(
              label: Text('About'),
              multiline: true,
              rows: 2,
              placeholder: 'A sentence or two.',
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
