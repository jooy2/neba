import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

class TextFieldSizes extends StatelessWidget {
  const TextFieldSizes({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 3,
      alignItems: NebaAlignItems.start,
      children: <Widget>[
        for (final NebaSize size in NebaSize.values)
          NebaFlex(
            wrap: true,
            spacing: 2,
            alignItems: NebaAlignItems.center,
            children: <Widget>[
              NebaTextField(size: size, placeholder: 'size ${size.name}'),
              NebaTextField(size: size, density: NebaDensity.compact, placeholder: 'compact'),
              NebaButton(
                onPressed: () {},
                size: size,
                variant: NebaVariant.outline,
                color: NebaColor.secondary,
                child: const Text('Same height'),
              ),
            ],
          ),
      ],
    );
  }
}
