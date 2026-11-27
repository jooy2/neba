import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

/// A link inside a sentence is a [WidgetSpan], set on the line's baseline.
WidgetSpan _inline(Widget link) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: link,
  );
}

class TextLinkHero extends StatelessWidget {
  const TextLinkHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 13, height: 22 / 13),
        child: NebaFlex(
          direction: NebaOrientation.vertical,
          spacing: 4,
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: 'Every component is documented on its own page, and the '),
                  _inline(
                    NebaTextLink(
                      onPressed: _open,
                      href: Uri.parse('/components/'),
                      child: const Text('component index'),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' lists them all with a live preview in each card. The design language '
                        'behind them is written up ',
                  ),
                  _inline(
                    NebaTextLink(
                      onPressed: _open,
                      href: Uri.parse('/design/design-language'),
                      color: NebaColor.primary,
                      child: const Text('here'),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                NebaTextLink(
                  onPressed: _open,
                  href: Uri.parse('https://neba.cdget.com/components/'),
                  newTab: true,
                  child: const Text('All components'),
                ),
                NebaTextLink(
                  onPressed: _open,
                  href: Uri.parse('/guide/getting-started'),
                  underline: NebaTextLinkUnderline.hover,
                  color: NebaColor.info,
                  child: const Text('Getting started'),
                ),
                NebaTextLink(
                  onPressed: _open,
                  href: Uri.parse('/components/inputs/button'),
                  underline: NebaTextLinkUnderline.none,
                  showIcon: true,
                  color: NebaColor.secondary,
                  child: const Text('Button'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
