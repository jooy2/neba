import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A title alone keeps the row one line tall, so the lozenge stays a stadium.
/// Adding a description grows it into a rounded rectangle with the same
/// corner.
class PillText extends StatelessWidget {
  const PillText({super.key});

  @override
  Widget build(BuildContext context) {
    return const NebaFlex(
      wrap: true,
      spacing: 4,
      alignItems: NebaAlignItems.center,
      children: <Widget>[
        NebaPill(startIcon: _Dot(), color: NebaColor.success, title: Text('All systems normal')),
        NebaPill(
          startIcon: _Dot(),
          color: NebaColor.warning,
          title: Text('Degraded'),
          description: Text('EU-west is slow'),
        ),
      ],
    );
  }
}

/// A filled dot, at the icon size and in the icon colour the pill sets.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final IconThemeData icon = IconTheme.of(context);
    final double size = icon.size ?? 16;

    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Container(
          width: size / 2,
          height: size / 2,
          decoration: BoxDecoration(color: icon.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
