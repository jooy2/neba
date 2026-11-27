import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class PopoverControlled extends StatefulWidget {
  const PopoverControlled({super.key});

  @override
  State<PopoverControlled> createState() => _PopoverControlledState();
}

class _PopoverControlledState extends State<PopoverControlled> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      wrap: true,
      spacing: 3,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaPopover(
          open: _open,
          onOpenChange: (bool open) => setState(() => _open = open),
          trigger: NebaButton(
            onPressed: () {},
            variant: NebaVariant.outline,
            child: const Text('Trigger'),
          ),
          title: const Text('Controlled'),
          child: const Text(
            'The caller owns the state, so anything else on the page can open or close this.',
          ),
        ),
        NebaButton(
          size: NebaSize.sm,
          variant: NebaVariant.text,
          onPressed: () => setState(() => _open = !_open),
          child: Text(_open ? 'Close from out here' : 'Open from out here'),
        ),
      ],
    );
  }
}
