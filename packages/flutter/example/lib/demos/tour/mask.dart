import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TourMask extends StatefulWidget {
  const TourMask({super.key});

  @override
  State<TourMask> createState() => _TourMaskState();
}

class _TourMaskState extends State<TourMask> {
  final GlobalKey _target = GlobalKey();
  // Running with the mask, without it, or not running at all.
  bool? _masked;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          NebaBox(
            key: _target,
            variant: NebaVariant.solid,
            color: NebaColor.secondary,
            child: const NebaTypography('The thing being pointed at.'),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              NebaButton(
                onPressed: () => setState(() => _masked = true),
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: const Text('With the mask'),
              ),
              NebaButton(
                onPressed: () => setState(() => _masked = false),
                size: NebaSize.sm,
                variant: NebaVariant.outline,
                child: const Text('Without it'),
              ),
            ],
          ),
          NebaTour(
            open: _masked != null,
            onOpenChange: (bool open) => setState(() => _masked = open ? _masked : null),
            mask: _masked ?? true,
            steps: <NebaTourStep>[
              NebaTourStep(
                target: _target,
                title: const Text('Here'),
                content: const Text(
                  'The dimming never takes the pointer — the page keeps working.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
