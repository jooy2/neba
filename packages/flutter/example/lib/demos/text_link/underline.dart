import 'package:flutter/widgets.dart';
import 'package:neba/neba.dart';

void _open() {}

class TextLinkUnderline extends StatelessWidget {
  const TextLinkUnderline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        NebaTextLink(onPressed: _open, child: Text('always')),
        NebaTextLink(
          onPressed: _open,
          underline: NebaTextLinkUnderline.hover,
          child: Text('hover'),
        ),
        NebaTextLink(
          onPressed: _open,
          underline: NebaTextLinkUnderline.none,
          color: NebaColor.primary,
          child: Text('none'),
        ),
      ],
    );
  }
}
