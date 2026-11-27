import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class VisuallyHiddenSkipLink extends StatefulWidget {
  const VisuallyHiddenSkipLink({super.key});

  @override
  State<VisuallyHiddenSkipLink> createState() => _VisuallyHiddenSkipLinkState();
}

class _VisuallyHiddenSkipLinkState extends State<VisuallyHiddenSkipLink> {
  final FocusNode _main = FocusNode(debugLabel: 'Main content');
  bool _focused = false;

  @override
  void dispose() {
    _main.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        // Hidden until the focus reaches it, then a control the reader sees.
        NebaVisuallyHidden(
          visible: _focused,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (bool focused) => setState(() => _focused = focused),
            child: NebaButton(
              onPressed: _main.requestFocus,
              size: NebaSize.sm,
              child: const Text('Skip to content'),
            ),
          ),
        ),
        Text(
          'Press Tab with this preview focused: the link appears, then hides again.',
          style: TextStyle(fontSize: 13, color: tokens.mutedFg),
        ),
        Focus(
          focusNode: _main,
          child: const NebaBox(child: Text('Main content')),
        ),
      ],
    );
  }
}
