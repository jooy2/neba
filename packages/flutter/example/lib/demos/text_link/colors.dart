import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class TextLinkColors extends StatelessWidget {
  const TextLinkColors({super.key});

  @override
  Widget build(BuildContext context) {
    return NebaFlex(
      direction: NebaOrientation.vertical,
      spacing: 4,
      children: <Widget>[
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 13, height: 22 / 13),
          child: const Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'With no color a link is '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: NebaTextLink(onPressed: _open, child: Text('the colour of the sentence')),
                ),
                TextSpan(text: ' it sits in.'),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final NebaColor color in NebaColor.values)
              NebaTextLink(onPressed: _open, color: color, child: Text(color.name)),
          ],
        ),
      ],
    );
  }
}
