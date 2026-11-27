import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class OverlayTones extends StatefulWidget {
  const OverlayTones({super.key});

  @override
  State<OverlayTones> createState() => _OverlayTonesState();
}

class _OverlayTonesState extends State<OverlayTones> {
  NebaOverlayTone? _tone;

  @override
  Widget build(BuildContext context) {
    final NebaOverlayTone? tone = _tone;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final NebaOverlayTone name in NebaOverlayTone.values)
          NebaButton(
            onPressed: () => setState(() => _tone = name),
            variant: NebaVariant.outline,
            child: Text(name.name),
          ),
        NebaOverlay(
          open: tone != null,
          onOpenChange: (bool open) {
            if (!open) {
              setState(() => _tone = null);
            }
          },
          tone: tone ?? NebaOverlayTone.scrim,
          dismissible: true,
          label: '${tone?.name} overlay',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              NebaTypography('tone: ${tone?.name}', level: NebaTypographyLevel.h4),
              NebaButton(onPressed: () => setState(() => _tone = null), child: const Text('Close')),
            ],
          ),
        ),
      ],
    );
  }
}
