import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OverlayDismissible extends StatefulWidget {
  const OverlayDismissible({super.key});

  @override
  State<OverlayDismissible> createState() => _OverlayDismissibleState();
}

class _OverlayDismissibleState extends State<OverlayDismissible> {
  bool _held = false;
  bool _loose = false;

  @override
  Widget build(BuildContext context) {
    final NebaTokens tokens = NebaTheme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        NebaButton(
          onPressed: () => setState(() => _held = true),
          variant: NebaVariant.outline,
          child: const Text('Cannot be dismissed'),
        ),
        NebaButton(
          onPressed: () => setState(() => _loose = true),
          variant: NebaVariant.outline,
          child: const Text('Press anywhere to close'),
        ),
        NebaOverlay(
          open: _held,
          label: 'Working',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: NebaCard(
              title: const Text('No way past this'),
              subtitle: const Text('Escape and a press outside are both refused.'),
              footer: NebaButton(
                onPressed: () => setState(() => _held = false),
                child: const Text('Let me out'),
              ),
            ),
          ),
        ),
        NebaOverlay(
          open: _loose,
          onOpenChange: (bool open) => setState(() => _loose = open),
          dismissible: true,
          label: 'Dismissible overlay',
          child: Text('Press the scrim, or press Escape.', style: TextStyle(color: tokens.fg)),
        ),
      ],
    );
  }
}
