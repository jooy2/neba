import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class ToastPositions extends StatefulWidget {
  const ToastPositions({super.key});

  @override
  State<ToastPositions> createState() => _ToastPositionsState();
}

class _ToastPositionsState extends State<ToastPositions> {
  NebaToastPosition _position = NebaToastPosition.bottomEnd;

  Widget _group(List<NebaToastPosition> positions) {
    return NebaButtonGroup(
      size: NebaSize.xs,
      variant: NebaVariant.outline,
      color: NebaColor.secondary,
      children: <Widget>[
        for (final NebaToastPosition option in positions)
          NebaButton(
            variant: option == _position ? NebaVariant.solid : NebaVariant.outline,
            onPressed: () => setState(() => _position = option),
            child: Text(option.name),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      alignItems: NebaAlignItems.start,
      spacing: 3,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 2,
          children: <Widget>[
            _group(NebaToastPosition.values.sublist(0, 3)),
            _group(NebaToastPosition.values.sublist(3)),
          ],
        ),
        // Keyed by the position, so the whole stack moves at once rather
        // than leaving the toasts already on screen behind.
        NebaToastProvider(
          key: ValueKey<NebaToastPosition>(_position),
          position: _position,
          width: 300,
          child: _Raise(position: _position),
        ),
      ],
    );
  }
}

class _Raise extends StatelessWidget {
  const _Raise({required this.position});

  final NebaToastPosition position;

  @override
  Widget build(BuildContext context) {
    return NebaButton(
      size: NebaSize.sm,
      onPressed: () => NebaToastProvider.of(context).add(
        NebaToastOptions(title: Text(position.name), timeout: const Duration(milliseconds: 2500)),
      ),
      child: const Text('Raise one here'),
    );
  }
}
