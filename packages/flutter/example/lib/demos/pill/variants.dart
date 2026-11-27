import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

/// A pill is a control as far as colour goes, not a container: its surface is
/// what takes the colour, as on a button or a chip.
class PillVariants extends StatelessWidget {
  const PillVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 5,
      children: <Widget>[
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaVariant variant in NebaVariant.values)
              NebaPill(
                variant: variant,
                color: NebaColor.primary,
                startIcon: const _Dot(),
                title: Text(variant.name),
              ),
          ],
        ),
        NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            for (final NebaSize size in const <NebaSize>[NebaSize.sm, NebaSize.md, NebaSize.lg])
              NebaPill(
                size: size,
                color: NebaColor.success,
                startIcon: const _Dot(),
                title: Text('size ${size.name}'),
              ),
          ],
        ),
        const NebaFlex(
          wrap: true,
          spacing: 3,
          alignItems: NebaAlignItems.center,
          children: <Widget>[
            NebaPill(
              density: NebaDensity.compact,
              color: NebaColor.secondary,
              startIcon: _Dot(),
              title: Text('compact'),
            ),
            NebaPill(
              elevation: 0,
              color: NebaColor.secondary,
              startIcon: _Dot(),
              title: Text('elevation 0'),
            ),
            NebaTypography(
              'Density is padding; elevation is how far it floats.',
              level: NebaTypographyLevel.caption,
            ),
          ],
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
